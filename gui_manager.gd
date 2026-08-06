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

var event_receiver: IEventReceiver
var _fading_overlay: Node
var _fading: int
var _fading_cause: int

static func instance() -> GUIManager:
	return (Engine.get_main_loop() as SceneTree).get_first_node_in_group(&"_ZN10GUIManager8InstancevE")


func _ready() -> void:
	for i in [$Fade, $Prototype]:
		# make these nodes internal for immunity to free_all_child
		remove_child(i)
		add_child(i, true, Node.INTERNAL_MODE_FRONT)


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
func add_image(texture_name: String, attr: ecTextureRect, gui_rect: GUIRect,
		parent:Node) -> GUIImage:
	var image = $Prototype/GUIImage.duplicate()
	image.rect = gui_rect
	var asset := AssetRegistry.new()
	asset.name = texture_name
	image.asset = asset
	image.texture_rect = attr
	if parent == null:
		parent = self
	parent.add_child(image)
	return image


func add_button(normal_image_name: StringName, pressed_image_name: StringName,
		gui_rect: GUIRect, parent:Node, font: NodePath) -> GUIButton:
	var button = $Prototype/GUIButton.duplicate()
	button.rect = gui_rect
	var asset := AssetRegistry.new()
	asset.name = normal_image_name
	button.image_normal = asset
	asset = AssetRegistry.new()
	asset.name = pressed_image_name
	button.image_pressed = asset
	button.font = font
	if parent == null:
		parent = self
	parent.add_child(button)
	return button


func add_scroll_bar(gui_rect: GUIRect, parent:Node, normal_image_name: StringName,
		pressed_image_name: StringName, grabber_size_w: int,
		grabber_size_h: int, default_value: int, set_max_value: int,
		is_horizontal: bool) -> GUIScrollBar:
	var scroll_bar = $Prototype/GUIScrollBar.duplicate()
	scroll_bar.rect = gui_rect
	var asset := AssetRegistry.new()
	asset.name = normal_image_name
	scroll_bar.image_normal = asset
	asset = AssetRegistry.new()
	asset.name = pressed_image_name
	scroll_bar.image_pressed = asset
	scroll_bar.grabber_size_ipad = Vector2(grabber_size_w, grabber_size_h)
	scroll_bar.grabber_size = Vector2(grabber_size_w, grabber_size_h)
	scroll_bar.value = default_value
	scroll_bar.max_value = set_max_value
	scroll_bar.horizontal = is_horizontal
	if parent == null:
		parent = self
	parent.add_child(scroll_bar)
	return scroll_bar


func fade_out(cause: int, overlay: Control) -> void:
	_fading_cause = cause
	_fading = 2
	if _fading_overlay != null:
		_fading_overlay.queue_free()
	if overlay != null:
		overlay.reparent($Fade, false)
		_fading_overlay = overlay


func fade_in(cause: int) -> void:
	_fading_cause = cause
	_fading = 1


func _process(delta: float) -> void:
	if _fading == 1:
		var a := maxf($Fade/Fade.alpha - 2.5 * delta, 0.0)
		$Fade/Fade.alpha = a
		if a <= 0.0:
			_fading = 0
			event_receiver.emit_faded_in(_fading_cause)
	elif _fading == 2:
		var a := minf($Fade/Fade.alpha + 2.5 * delta, 1.0)
		$Fade/Fade.alpha = a
		if a >= 1.0:
			if _fading_overlay != null:
				_fading_overlay.queue_free()
			_fading = 0
			event_receiver.emit_faded_out(_fading_cause)
