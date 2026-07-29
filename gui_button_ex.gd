@tool
extends GUIButton

@export
var image_text_normal: AssetRegistry:
	set(value):
		if value != image_text_normal:
			if image_text_normal != null:
				image_text_normal.changed.disconnect(init)
			image_text_normal = value
			init()
			if value != null:
				value.changed.connect(init, CONNECT_REFERENCE_COUNTED)


@export
var image_text_pressed: AssetRegistry:
	set(value):
		if value != image_text_pressed:
			if image_text_pressed != null:
				image_text_pressed.changed.disconnect(init)
			image_text_pressed = value
			init()
			if value != null:
				value.changed.connect(init, CONNECT_REFERENCE_COUNTED)


@export
var texture_text_not_pressed: Texture2D:
	set(value):
		if value != texture_text_not_pressed:
			texture_text_not_pressed = value
			_on_render()


@export
var texture_text_pressed: Texture2D:
	set(value):
		if value != texture_text_pressed:
			texture_text_pressed = value
			_on_render()


@export
var image_position_ipad: Vector2:
	set(value):
		if value != image_position_ipad:
			image_position_ipad = value
			_on_render()


@export
var image_position: Vector2:
	set(value):
		if value != image_position:
			image_position = value
			_on_render()


func init() -> void:
	if not is_node_ready():
		return
	super()
	var res := texture_res
	if res == null:
		res = s_texture_res
	if res != null:
		if image_text_normal != null:
			if Engine.is_editor_hint():
				texture_text_not_pressed = texture_res.get_image(image_text_normal.name)
				if texture_text_not_pressed == null:
					texture_text_not_pressed = texture_res.get_image(image_text_normal.name_hd)
			else:
				var image_name := image_text_normal.get_resolved_name()
				if not image_name.is_empty():
					texture_text_not_pressed = res.get_image(image_name)
		if image_text_pressed != null:
			if Engine.is_editor_hint():
				texture_text_pressed = texture_res.get_image(image_text_pressed.name)
				if texture_text_pressed == null:
					texture_text_pressed = texture_res.get_image(image_text_pressed.name_hd)
			else:
				var image_name := image_text_pressed.get_resolved_name()
				if not image_name.is_empty():
					texture_text_pressed = res.get_image(image_name)
	notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if image_text_normal != null and property.name == "texture_text_not_pressed":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if image_text_pressed != null and property.name == "texture_text_pressed":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY


#func set_image_text(value_not_pressed: String, value_pressed: String) -> void:
	#var attr := s_texture_res.get_image(value_not_pressed)
	#if attr != null:
		#texture_text_not_pressed = _ecImageTexture.from_ec_image_attr(attr)
	#attr = s_texture_res.get_image(value_pressed)
	#if attr != null:
		#texture_text_pressed = _ecImageTexture.from_ec_image_attr(attr)


func _on_render():
	super()
	if ecGraphics.instance().content_scale_size_mode == 3:
		$ExText.position = image_position_ipad
	else:
		$ExText.position = image_position
	if $TextureButton.button_pressed:
		$ExText.texture = texture_text_pressed
		$ExText.self_modulate = Color(Color8(0xD2, 0xD2, 0xD2), alpha)
	else:
		$ExText.texture = texture_text_not_pressed
		$ExText.self_modulate = Color(Color8(0xFF, 0xFF, 0xFF), alpha)
	if not enable:
		$ExText.self_modulate = Color(Color8(0x6E, 0x6E, 0x6E), alpha)
