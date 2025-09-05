extends Control

## In the original game code, GUIManager::Instance() is the root of GUIElement
## tree. It is mostly controlled by the current state: its children are
## populated by the current state in OnEnter, and signals from the children are
## forwarded to the current state.
## 
## Additionally, GUIManager provides the following functionalities:
## 1) hold a ecTextureRes
## 2) fade in and fade out (initially faded out and immediately starts fading in)
## 3) safely (deferred) remove child
## 4) add simple child element
## 
## In this Godot port, GUIManager is still supposed to be used as the root of UI
## elements, but is not a singleton. It is typically created and its children
## populated by a PackedScene. The current state should connect the signal the
## replace the generated event. The other functionalities will be added if
## necessary.

var _fading_tween: Tween

signal faded_in(int)
signal faded_out(int)

func _ready() -> void:
	$Fade.visible = true # $Fade is invisible in the editor for previewing
	fade_in(0)


func fade_in(cause: int) -> void:
	if _fading_tween != null:
		_fading_tween.kill()
	_fading_tween = create_tween()
	var c := Color.BLACK
	c.a = 0.0
	var _fade_node: ColorRect = $Fade
	var t := _fade_node.color.a
	_fading_tween.tween_property(_fade_node, ^"color", c, t)
	_fading_tween.tween_callback(func():
		_fading_tween = null
		faded_in.emit(cause)
	)


func fade_out(cause: int, on_top: Control) -> void:
	if on_top != null:
		add_child(on_top)
	if _fading_tween != null:
		_fading_tween.kill()
	_fading_tween = create_tween()
	var _fade_node: ColorRect = $Fade
	var t = 1.0 - _fade_node.color.a
	_fading_tween.tween_property(_fade_node, ^"color", Color.BLACK, t)
	_fading_tween.tween_callback(func():
		_fading_tween = null
		faded_out.emit(cause)
	)
