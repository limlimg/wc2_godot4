@tool
extends GUIButton

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
