class_name CBaseState
extends Control

## In the original game code, CBaseState is the base class of states which are
## the primary controllers of the game's behavour.
##
## In this Godot port, states do not have to inherit this class, and it is
## preferred to use node callbacks. CStateManager invokes the current scene
## in a duck-typed manner, so defining one of the following method is enough
## to allow it to be called, while it is not necessary to define all of them.

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_node_ready():
			if visible:
				_on_enter()
			else:
				_on_exit()
	if what == NOTIFICATION_APPLICATION_RESUMED:
		_enter_foreground()
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		_enter_background()


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_begin(event.position.x, event.position.y, event.index)
		else:
			_touch_end(event.position.x, event.position.y, event.index)
	elif event is InputEventScreenDrag:
		_touch_move(event.position.x, event.position.y, event.index)
	elif event.is_action_pressed(&"ui_cancel"):
		if _back_pressed():
			get_viewport().set_input_as_handled()


func _touch_begin(_x: float, _y: float, _index: float) -> void:
	pass


func _touch_move(_x: float, _y: float, _index: float) -> void:
	pass


func _touch_end(_x: float, _y: float, _index: float) -> void:
	pass


func _back_pressed() -> bool:
	return false


func _key_down(_key: Key) -> void:
	pass


func _scroll_wheel(_x_value: float, _y_value: float, _a3: float) -> void:
	pass


func _enter_background() -> void:
	pass


func _enter_foreground() -> void:
	pass
