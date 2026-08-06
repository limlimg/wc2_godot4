@tool
class_name GUIScrollBar
extends GUIElement

@export
var image_normal: AssetRegistry:
	set(value):
		if value != image_normal:
			if image_normal != null:
				image_normal.changed.disconnect(init)
			image_normal = value
			init()
			if value != null:
				value.changed.connect(init, CONNECT_REFERENCE_COUNTED)


@export
var image_pressed: AssetRegistry:
	set(value):
		if value != image_pressed:
			if image_pressed != null:
				image_pressed.changed.disconnect(init)
			image_pressed = value
			init()
			if value != null:
				value.changed.connect(init, CONNECT_REFERENCE_COUNTED)


@export
var horizontal: bool:
	get():
		return $HSlider.visible
	set(value):
		$HSlider.visible = value
		$VSlider.visible = not value


@export
var max_value: float:
	get():
		return $HSlider.max_value if horizontal else $VSlider.max_value
	set(value):
		var f: float
		f = $VSlider.value * (value / $VSlider.max_value)
		$VSlider.max_value = value
		$VSlider.set_value_no_signal(f)
		f = $HSlider.value * (value / $HSlider.max_value)
		$HSlider.max_value = value
		$VSlider.set_value_no_signal(f)


@export
var value: float:
	get = get_scroll_pos,
	set = set_scroll_pos


@export
var grabber_size_ipad: Vector2:
	set(value):
		if value != grabber_size_ipad:
			grabber_size_ipad = value
			_on_render()


@export
var grabber_size: Vector2:
	set(value):
		if value != grabber_size:
			grabber_size = value
			_on_render()


@export_group("Textures", "texture_")
@export
var texture_normal: Texture2D:
	get():
		return $Grabber.texture_normal
	set(value):
		$Grabber.texture_normal = value


@export
var texture_pressed: Texture2D:
	get():
		return $Grabber.texture_pressed
	set(value):
		$Grabber.texture_pressed = value


signal value_changed(value: float)

func _ready() -> void:
	super()
	_on_render()


func init() -> void:
	if not is_node_ready():
		return
	super()
	var res := texture_res
	if res == null:
		res = s_texture_res
	if res != null:
		if image_normal != null:
			texture_normal = res.get_image(image_normal.get_resolved_name())
		if image_pressed != null:
			texture_pressed = res.get_image(image_pressed.get_resolved_name())
	notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if image_normal != null and property.name == "texture_normal":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if image_pressed != null and property.name == "texture_pressed":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY


func _on_render() -> void:
	if ecGraphics.instance().content_scale_size_mode == 3:
		$Grabber.size = grabber_size_ipad
	else:
		$Grabber.size = grabber_size
	var range_size = size - $Grabber.size
	var proportion := Vector2($HSlider.value / $HSlider.max_value, $VSlider.value / $VSlider.max_value)
	$Grabber.position = range_size * proportion


func get_scroll_pos() -> float:
	return $HSlider.value if horizontal else $VSlider.value


func set_scroll_pos(pos: float) -> void:
	if horizontal:
		$HSlider.set_value_no_signal(pos)
	else:
		$VSlider.set_value_no_signal(pos)
	_on_render()


# inspector connection cannot bind and unbind arguments at the same time
func _on_drag_ended() -> void:
	$Grabber.set_pressed_no_signal(false)


func _on_value_changed(_value: float) -> void:
	_on_render()
	value_changed.emit(_value)
