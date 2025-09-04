extends Control

## In the original game code, GUIManager::Instance() is the root of GUIElement
## tree. It is mostly controlled by the current state: its children are
## populated by the current state in OnEnter, and signals from the children are
## forwarded to the current state.
## 
## Additionally, GUIManager provides the following functionalities:
## 1) hold a ecTextureRes
## 2) fade in and fade out
## 3) safely (deferred) remove child
## 4) add simple child element
## 
## In this Godot port, GUIManager is still supposed to be used as the root of UI
## elements, but is not a singleton. It is typically created and its children
## populated by a PackedScene. The current state should connect the signal the
## replace the generated event. The other functionalities will be added if
## necessary.

var _fade_node: ColorRect
var _fading_tween: Tween

signal faded_in(int)
signal faded_out(int)

func _ready() -> void:
	_create_fade_node()
	_fade_node.color = Color.BLACK


func _create_fade_node() -> void:
	_fade_node = ColorRect.new()
	_fade_node.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_node.z_index = 1
	_fade_node.color = Color.BLACK
	_fade_node.color.a = 0.0
	add_child(_fade_node)


func fade_in(param: int) -> void:
	if _fade_node == null:
		return
	if _fading_tween != null:
		_fading_tween.kill()
	_fading_tween = create_tween()
	var c := Color.BLACK
	c.a = 0.0
	var t := _fade_node.color.a
	_fading_tween.tween_property(_fade_node, ^"color", c, t)
	_fading_tween.tween_callback(func():
		remove_child(_fade_node)
		_fade_node.queue_free()
		_fade_node = null
		_fading_tween = null
		faded_in.emit(param)
	)


func fade_out(param: int, on_top: Control) -> void:
	if _fade_node == null:
		_create_fade_node()
	if on_top != null:
		add_child(on_top)
	if _fading_tween != null:
		_fading_tween.kill()
	_fading_tween = create_tween()
	var t = 1.0 - _fade_node.color.a
	_fading_tween.tween_property(_fade_node, ^"color", Color.BLACK, t)
	_fading_tween.tween_callback(func():
		_fading_tween = null
		faded_out.emit(param)
	)
