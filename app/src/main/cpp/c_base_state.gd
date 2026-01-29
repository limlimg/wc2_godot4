extends Node

## In the original game code, CBaseState is the base class of states which are
## the primary controllers of the game's behavour.
##
## In this Godot port, states do not have to inherit this class, and it is
## preferred to use node callbacks. CStateManager invokes the current scene
## in a duck-typed manner, so defining one of the following method is enough
## to allow it to be called, while it is not necessary to define all of them.


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	pass

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
