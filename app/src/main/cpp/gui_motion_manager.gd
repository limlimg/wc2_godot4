extends Node

## GUIMotionManager is frame rate dependent: it has a method that is called
## every frame without the time difference parameter.
## 
## In this Godot port, GUIMotionManager is instantiated as an Autoload so that
## it receives the update call directly from the engine. Like GUIElements, it
## uses signal instead of Event to inform the current state of the finishing
## of a motion.

const _GUIMotionManager = preload("res://app/src/main/cpp/gui_motion_manager.gd")

class _GUIMotion:
	var node: Control
	var start: Vector2
	var target: Vector2
	var cur: Vector2
	var speed: Vector2
	var delay: int
	var delay_remaining: int
	var flag: int

var _motion: Array[_GUIMotion]
var _active_motion: Array[_GUIMotion]
var _frozen: bool

signal motion_finished(Control)

func instance() -> _GUIMotionManager:
	return GUIMotionManager


func clear_motion() -> void:
	_motion.clear()
	_active_motion.clear()
	_frozen = false


func add_motion(node: Control, start_x: float, start_y: float, target_x: float,
		target_y: float, speed: float, delay: int) -> _GUIMotion:
	if node == null:
		return null
	var motion := _GUIMotion.new()
	motion.node = node
	set_motion(motion, start_x, start_y, target_x, target_y, speed, delay)
	motion.flag = 0
	_motion.append(motion)
	return motion


func add_motion_from_current_position(node: Control, target_x: float,
		target_y: float, speed: float, delay: int) -> _GUIMotion:
	if node == null:
		return null
	var pos := node.position
	return add_motion(node, pos.x, pos.y, target_x, target_y, speed, delay)


func add_motion_x(node: Control, target_x: float, speed: float, delay: int) -> _GUIMotion:
	if node == null:
		return null
	var pos := node.position
	return add_motion(node, pos.x, pos.y, target_x, pos.y, speed, delay)


func add_motion_y(node: Control, target_y: float, speed: float, delay: int) -> _GUIMotion:
	if node == null:
		return null
	var pos := node.position
	return add_motion(node, pos.x, pos.y, pos.x, target_y, speed, delay)


func set_motion(motion: _GUIMotion, start_x: float, start_y: float,
		target_x: float, target_y: float, speed: float, delay: int) -> void:
	if motion == null:
		return
	motion.start = Vector2(start_x, start_y)
	motion.target = Vector2(target_x, target_y)
	motion.speed = (motion.target - motion.start).normalized() * speed
	motion.delay = delay


func _set_speed(motion: _GUIMotion, x: float, y: float) -> void:
	motion.speed = Vector2(x, y)


func active_motion(motion: _GUIMotion, flag: int) -> void:
	if motion == null or (motion.flag & 1) != 0:
		return
	var reverse := (flag & (1 << 1)) != 0
	motion.flag = flag | 1
	motion.cur = motion.target if reverse else motion.start
	motion.delay_remaining = motion.delay
	_active_motion.append(motion)


func _get_motion_active(motion: _GUIMotion) -> bool:
	return (motion.flag & 1) != 0


func _proc_motion() -> bool:
	if _frozen:
		return false
	if _active_motion.is_empty():
		return false
	var report_any := false
	for motion: _GUIMotion in _active_motion.duplicate(): # will remove element in the loop
		if motion.delay_remaining > 0:
			motion.delay_remaining -= 1
		else:
			var flag := motion.flag
			var reverse := (flag & (1 << 1)) != 0
			var loop := (flag & (1 << 2)) != 0
			var report := (flag & (1 << 3)) != 0
			var target := motion.start if reverse else motion.target
			if motion.cur == target:
				if loop:
					motion.cur = motion.target if reverse else motion.start
				else:
					motion.flag = flag & ~1
					_active_motion.erase(motion)
				motion_finished.emit(motion.node)
			else:
				# make sure to move towards the target position
				var target_sign := (target - motion.cur).sign()
				var speed_sign := motion.speed.sign()
				var d := motion.speed * speed_sign * target_sign
				var new_pos := motion.cur + d
				# do not move beyond the target position
				var new_sign := (target - new_pos).sign()
				if new_sign.x != target_sign.x:
					new_pos.x = target.x
				if new_sign.y != target_sign.y:
					new_pos.y = target.y
				motion.node.position = new_pos
				if report:
					report_any = true
	return report_any


func _physics_process(_delta: float) -> void:
	_proc_motion()
