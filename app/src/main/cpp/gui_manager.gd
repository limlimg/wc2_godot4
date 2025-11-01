extends "res://app/src/main/cpp/gui_element.gd"

## In the original game code, GUIManager::Instance() is the root of GUIElement
## tree. It is mostly controlled by the current state: its children are
## populated by the current state in OnEnter, and signals from the children are
## forwarded to the current state.
## 
## Additionally, GUIManager provides the following functionalities:
## 1) hold a ecTextureRes that is used by GUIButton and GUIScrollBar
## 2) fade in and fade out (initially faded out and immediately starts fading in)
## 3) safely (deferred) remove child
## 4) add simple child element
## 
## In this Godot port, GUIManager is still supposed to be used as the root of UI
## elements, but is not a singleton. It is typically created and its children
## populated by the current state as a PackedScene. The current state should
## connect the signal the replace the generated event. The other functionalities
## will be added if necessary.
##
## PostEvent is not implemented because the original event system is not used
## any more.

const _ecTextureRect = preload("res://app/src/main/cpp/ec_texture_rect.gd")
const _GUIImage = preload("res://app/src/main/cpp/gui_image.gd")
const _GUI_IMAGE = preload("res://app/src/main/cpp/gui_image.tscn")
const _ecUniFont = preload("res://app/src/main/cpp/ec_uni_font.gd")
const _GUIButton = preload("res://app/src/main/cpp/gui_button.gd")
const _GUI_BUTTON = preload("res://app/src/main/cpp/gui_button.tscn")
const _GUIScrollBar = preload("res://app/src/main/cpp/gui_scroll_bar.gd")
const _GUI_SCROLL_BAR = preload("res://app/src/main/cpp/gui_scroll_bar.tscn")

var _fading_tween: Tween

signal faded_in(int)
signal faded_out(int)

func init(rect: Rect2) -> void:
	position = rect.position
	size = rect.size


func load_texture_res(file_name: String, hd: bool) -> void:
	_s_texture_res.load_res(file_name, hd)


func unload_texture_res(file_name: String) -> void:
	_s_texture_res.unload_res(file_name)


func release_texture_res() -> void:
	_s_texture_res.release()


func safe_free_child(child: Node) -> void:
	(func ():
		child.get_parent().remove_child(child)
		child.free()
	).call_deferred()


## The original method has more parameter for specifying texture format.
func add_image_texture(texture_name: String, attr: _ecTextureRect, rect: Rect2,
		parent:Node) -> _GUIImage:
	var image := _GUI_IMAGE.instantiate()
	if not image.init_atlas(texture_name, attr, rect):
		image.free()
		return null
	if parent == null:
		parent = self
	parent.add_child(image)
	return image


func add_image(texture_name: String, rect: Rect2, parent:Node) -> _GUIImage:
	var image := _GUI_IMAGE.instantiate()
	if not image.init_image_attr(texture_name, rect):
		image.free()
		return null
	if parent == null:
		parent = self
	parent.add_child(image)
	return image


func add_button(normal_image_name: StringName, pressed_image_name: StringName,
		rect: Rect2, parent:Node, font: _ecUniFont) -> _GUIButton:
	var button := _GUI_BUTTON.instantiate()
	button.init(normal_image_name, pressed_image_name, rect, font)
	if parent == null:
		parent = self
	parent.add_child(button)
	return button


func add_scroll_bar(rect: Rect2, parent:Node, normal_image_name: StringName,
		pressed_image_name: StringName, grabber_size_w: int,
		grabber_size_h: int, default_value: int, set_max_value: int,
		is_horizontal: bool) -> _GUIScrollBar:
	var scroll_bar := _GUI_SCROLL_BAR.instantiate()
	scroll_bar.init(rect, normal_image_name, pressed_image_name, grabber_size_w,
		grabber_size_h, default_value, set_max_value, is_horizontal)
	if parent == null:
		parent = self
	parent.add_child(scroll_bar)
	return scroll_bar


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


func _ready() -> void:
	$Fade.visible = true # $Fade is invisible in the editor for previewing
	fade_in(0)
