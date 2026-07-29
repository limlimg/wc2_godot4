class_name GUIManager
extends GUIElement

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

var _fade_order := 0

signal faded_in(cause: int)
signal faded_out(cause: int)

static func instance() -> GUIManager:
	return (Engine.get_main_loop() as SceneTree).get_first_node_in_group(&"_ZN10GUIManager8InstancevE")


func _ready() -> void:
	for i in [$Fade, $Prototype, $AnimationPlayer]:
		# make these nodes internal for immunity to free_all_child
		remove_child(i)
		add_child(i, true, Node.INTERNAL_MODE_BACK)


func init() -> void:
	# nothing to do
	pass


func load_texture_res(file_name: String, hd: bool) -> void:
	s_texture_res.load_res(file_name, hd)


func unload_texture_res(file_name: String) -> void:
	s_texture_res.unload_res(file_name)


func release_texture_res() -> void:
	s_texture_res.release()


func safe_free_child(child: Node) -> void:
	child.queue_free()


## The original method has more parameter for specifying texture format.
func add_image_texture(texture_name: String, attr: ecTextureRect, gui_rect: Rect2,
		parent:Node) -> GUIImage:
	var image = $Prototype/GUIImage.create_instance()
	image.rect = gui_rect
	if not image.set_image(texture_name, attr):
		image.free()
		return null
	if parent == null:
		parent = self
	image.reparent(parent)
	return image


func add_image(texture_name: String, gui_rect: Rect2, parent:Node) -> GUIImage:
	var image = $Prototype/GUIImage.create_instance()
	image.rect = gui_rect
	if not image.set_image(texture_name):
		image.free()
		return null
	if parent == null:
		parent = self
	image.reparent(parent)
	return image


func add_button(normal_image_name: StringName, pressed_image_name: StringName,
		gui_rect: Rect2, parent:Node, font: ecUniFont) -> GUIButton:
	var button = $Prototype/GUIButton.create_instance()
	button.init(normal_image_name, pressed_image_name, gui_rect, font)
	if parent == null:
		parent = self
	parent.reparent(button)
	return button


func add_scroll_bar(gui_rect: Rect2, parent:Node, normal_image_name: StringName,
		pressed_image_name: StringName, grabber_size_w: int,
		grabber_size_h: int, default_value: int, set_max_value: int,
		is_horizontal: bool) -> GUIScrollBar:
	var scroll_bar = $Prototype/GUIScrollBar.create_instance()
	scroll_bar.init(gui_rect, normal_image_name, pressed_image_name, grabber_size_w,
		grabber_size_h, default_value, set_max_value, is_horizontal)
	if parent == null:
		parent = self
	parent.reparent(scroll_bar)
	return scroll_bar


func fade_in(cause: int) -> void:
	_fade_order += 1
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.animation_finished.emit(&"fade_out") # to remove overlay
	if $Fade/Fade.alpha != 0.0:
		$AnimationPlayer.play_section(&"fade_in", (1.0 - $Fade/Fade.alpha) * 0.4)
	else:
		$AnimationPlayer.animation_finished.emit.call_deferred(&"fade_in")
	var waiting_fade_order := _fade_order
	var anim_name: StringName = await $AnimationPlayer.animation_finished
	if anim_name == &"fade_in" and _fade_order == waiting_fade_order:
		faded_in.emit(cause)


func fade_out(cause: int, overlay: Control) -> void:
	_fade_order += 1
	if overlay != null:
		overlay.reparent($Fade, false)
	if $Fade/Fade.alpha != 1.0:
		$AnimationPlayer.play_section(&"fade_out", ($Fade/Fade.alpha) * 0.4)
	else:
		$AnimationPlayer.animation_finished.emit.call_deferred(&"fade_out")
	var waiting_fade_order := _fade_order
	var anim_name: StringName = await $AnimationPlayer.animation_finished
	if overlay != null:
		overlay.queue_free()
	if anim_name == &"fade_out" and _fade_order == waiting_fade_order:
		faded_out.emit(cause)
