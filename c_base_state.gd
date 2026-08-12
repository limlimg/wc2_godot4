class_name CBaseState
extends Control

## In the original game code, CBaseState is the base class of states which are
## the primary controllers of the game's behavour.
##
## In this Godot port, states do not have to inherit this class, and it is
## preferred to use node callbacks. CStateManager invokes the current scene
## in a duck-typed manner, so defining one of the following method is enough
## to allow it to be called, while it is not necessary to define all of them.

@export
var state: int

var _entered := false:
	set(value):
		_entered = value
		set_process(value)
		set_process_unhandled_input(value)


func _ready() -> void:
	set_process(false)
	set_process_unhandled_input(false)


func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree() and not _entered:
			_on_enter()
			_entered = true
		elif _entered:
			_entered = false
			_on_exit()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _entered:
			_entered = false
			_on_exit()
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		if _entered:
			_enter_foreground()
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		if _entered:
			_enter_background()


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	pass


func _enter_background() -> void:
	pass


func _enter_foreground() -> void:
	pass
