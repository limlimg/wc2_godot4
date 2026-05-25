extends Control

## CTouchInertia simulates a gradual slowdown of the dragging when the
## player untouch the screen. It is used by scrollable menus and moving
## of the map in-game. In the original code, the code of these machanisms
## create an instance and invoke its methods in input handling and update.
## 
## In this Godot port, for the sake of disentanglement and following the
## observer pattern, CTouchInertia handles inputs and update by itself,
## and the actual receiver connects to it. CTouchInertia is implemented as
## a Control node and should cover the area of the actual receiver.

@export
## per frame
var accleration := -150.0

@export
var deadzone := 10.0

var _speed := 0.0
var _speed_cos: float
var _speed_sin: float
var _touching := false
var _touch_index := 0
var _track_point: PackedFloat32Array
var _touch_time: float
var _touch_moved := false

signal touch_began(position: Vector2)
signal touch_moved(relative: Vector2)
signal touch_ended(position: Vector2, moved: bool)
signal inertia_ended()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_begin(event.position.x, event.position.y, event.index):
				touch_began.emit(event.position)
				accept_event()
		else:
			if _touch_end(event.position.x, event.position.y, event.index):
				touch_ended.emit(event.position, _touch_moved)
				accept_event()
	elif event is InputEventScreenDrag:
		if _touch_move(event.position.x, event.position.y, event.index):
			touch_moved.emit(event.relative)
			accept_event()


func _touch_begin(x: float, y: float, index: int) -> bool:
	if _touching:
		return false
	_touch_index = index
	_track_point.clear()
	_touching = true
	_touch_time = 0.0
	_touch_moved = false
	_add_track_point(x, y)
	set_physics_process(true)
	return true


func _add_track_point(x: float, y: float) -> void:
	@warning_ignore("integer_division")
	var n = _track_point.size()
	if n > 12:
		for i in 12:
			_track_point[i] = _track_point[i + 3]
	else:
		_track_point.resize(n + 3)
	_track_point[-3] = x
	_track_point[-2] = y
	_track_point[-1] = _touch_time


func _touch_move(x: float, y: float, index: int) -> bool:
	if not _touching or index != _touch_index:
		return false
	var start_point = _get_start_point()
	if absf(x - start_point[0]) > deadzone or absf(y - start_point[1]) > deadzone:
		_touch_moved = true
	_add_track_point(x, y)
	return true


func _touch_end(x: float, y: float, index: int) -> bool:
	if not _touching or index != _touch_index:
		return false
	_add_track_point(x, y)
	_touching = false
	_speed = 0.0
	if _touch_time > 0.01 and _track_point.size() > 1:
		var s := _get_start_point()
		if _touch_time > s[2] + 0.01:
			var dx := x - s[0]
			var dy := y - s[1]
			var d2 := dx * dx + dy * dy
			if d2 > 9.0:
				var d := sqrt(d2)
				_speed = d / (_touch_time - s[2])
				_speed_cos = dx / d
				_speed_sin = dy / d
	return true


func _get_start_point() -> PackedFloat32Array:
	var i := 2
	var n := _track_point.size() - 3
	while i < n and _track_point[i] < _touch_time - 1.0:
		i += 3
	return _track_point.slice(i - 2, i + 1)


func _physics_process(delta: float) -> void:
	_update(delta)


func _update(delta: float) -> void:
	if _touching:
		_touch_time += delta
	elif _speed > 0.0:
		_speed += accleration
		if _speed > 0.0:
			touch_moved.emit(_get_speed() * delta)
		else:
			_speed = 0.0
			inertia_ended.emit()
			set_physics_process(false)


func _get_speed() -> Vector2:
	return Vector2(_speed_cos, _speed_sin) * _speed


func _stop() -> void:
	_speed = 0.0
	_touching = false
	set_physics_process(false)
