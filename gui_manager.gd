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

signal faded_in(cause: int)
signal faded_out(cause: int)

static func instance() -> GUIManager:
	return (Engine.get_main_loop() as SceneTree).get_first_node_in_group(&"GUIManagerInstance")


#func load_texture_res(file_name: String, hd: bool) -> void:
	#s_texture_res.load_res(file_name, hd)
#
#
#func unload_texture_res(file_name: String) -> void:
	#s_texture_res.unload_res(file_name)
#
#
#func release_texture_res() -> void:
	#s_texture_res.release()


func safe_free_child(child: Node) -> void:
	child.queue_free()


## The original method has more parameter for specifying texture format.
func add_image_texture(texture_name: String, attr: ecTextureRect, rect: Rect2,
		parent:Node) -> GUIImage:
	var image := $Prototype/GUIImage.duplicate()
	if not image.init_atlas(texture_name, attr, rect):
		image.free()
		return null
	if parent == null:
		parent = self
	parent.add_child(image)
	return image


func add_image(texture_name: String, rect: Rect2, parent:Node) -> GUIImage:
	var image := $Prototype/GUIImage.duplicate()
	if not image.init_image_attr(texture_name, rect):
		image.free()
		return null
	if parent == null:
		parent = self
	parent.add_child(image)
	return image


func add_button(normal_image_name: StringName, pressed_image_name: StringName,
		rect: Rect2, parent:Node, font: ecUniFont) -> GUIButton:
	var button := $Prototype/GUIButton.duplicate()
	button.init(normal_image_name, pressed_image_name, rect, font)
	if parent == null:
		parent = self
	parent.add_child(button)
	return button


func add_scroll_bar(rect: Rect2, parent:Node, normal_image_name: StringName,
		pressed_image_name: StringName, grabber_size_w: int,
		grabber_size_h: int, default_value: int, set_max_value: int,
		is_horizontal: bool) -> GUIScrollBar:
	var scroll_bar := $Prototype/GUIScrollBar.duplicate()
	scroll_bar.init(rect, normal_image_name, pressed_image_name, grabber_size_w,
		grabber_size_h, default_value, set_max_value, is_horizontal)
	if parent == null:
		parent = self
	parent.add_child(scroll_bar)
	return scroll_bar


func fade_in(cause: int) -> void:
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.animation_finished.emit($AnimationPlayer.current_animation)
		#$AnimationPlayer.stop()
	var fading_cause := cause
	print("fade_in", fading_cause)
	$AnimationPlayer.play("fade_in")
	var anim_name: StringName = await $AnimationPlayer.animation_finished
	if anim_name == &"fade_in":
		print("faded_in", fading_cause)
		faded_in.emit(fading_cause)


func fade_out(cause: int, overlay: Control) -> void:
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.animation_finished.emit($AnimationPlayer.current_animation)
		#$AnimationPlayer.stop()
	var fading_cause := cause
	if overlay != null:
		overlay.reparent($Fade, false)
	print("fade_out", fading_cause)
	$AnimationPlayer.play("fade_out")
	var anim_name: StringName = await $AnimationPlayer.animation_finished
	if anim_name == &"fade_out":
		if overlay != null:
			overlay.queue_free()
		print("faded_out", fading_cause)
		faded_out.emit(fading_cause)
