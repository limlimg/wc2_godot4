extends Node

## CTouchInertia simulates a gradual slowdown of the dragging when the
## player untouch the screen. It is used by scrollable menus and moving
## of the map in-game. In the original code, the code of these machanisms
## create an instance and invoke its methods in input handling and update.


@export
## per frame
var accleration := -150.0

@export
var deadzone := 10.0

var touching := false
var _speed := 0.0
var _speed_cos: float
var _speed_sin: float
var _touch_index := 0
var _track_point: PackedFloat32Array
var _touch_time: float
var _touch_moved := false

func touch_begin(x: float, y: float, index: int) -> bool:
	if touching:
		return false
	_touch_index = index
	_track_point.clear()
	touching = true
	_touch_time = 0.0
	_touch_moved = false
	_add_track_point(x, y)
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


func touch_move(x: float, y: float, index: int) -> bool:
	if not touching or index != _touch_index:
		return false
	var start_point = _get_start_point()
	if absf(x - start_point[0]) > deadzone or absf(y - start_point[1]) > deadzone:
		_touch_moved = true
	_add_track_point(x, y)
	return true


func touch_end(x: float, y: float, index: int) -> bool:
	if not touching or index != _touch_index:
		return false
	_add_track_point(x, y)
	touching = false
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
	return not _touch_moved


func _get_start_point() -> PackedFloat32Array:
	var i := 2
	var n := _track_point.size() - 3
	while i < n and _track_point[i] >= _touch_time - 1.0:
		i += 3
	return _track_point.slice(i - 2, i + 1)


func update(delta: float) -> void:
	if touching:
		_touch_time += delta
	elif _speed > 0.0:
		_speed += accleration
		if _speed < 0.0:
			_speed = 0.0



func get_speed() -> Vector2:
	return Vector2(_speed_cos, _speed_sin) * _speed


func stop() -> void:
	_speed = 0.0
	touching = false
	set_physics_process(false)
