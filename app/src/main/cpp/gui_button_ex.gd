@tool
extends "res://app/src/main/cpp/gui_button.gd"

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
		image_position_ipad = value
		if not Engine.is_editor_hint() and _ecGraphics.instance().content_scale_size_mode == 3:
			$TextureRect.position = value


@export
var image_position: Vector2:
	set(value):
		image_position = value
		if Engine.is_editor_hint() or _ecGraphics.instance().content_scale_size_mode != 3:
			$TextureRect.position = value


func set_image_text(value_not_pressed: String, value_pressed: String) -> void:
	var attr := s_texture_res.get_image(value_not_pressed)
	if attr != null:
		texture_text_not_pressed = _ecImageTexture.from_ec_image_attr(attr)
	attr = s_texture_res.get_image(value_pressed)
	if attr != null:
		texture_text_pressed = _ecImageTexture.from_ec_image_attr(attr)


func _on_render():
	super()
	var texture_rect: TextureRect = $TextureRect
	if _texture_button.button_pressed:
		texture_rect.texture = texture_text_pressed
		texture_rect.self_modulate = Color(0xD2, 0xD2, 0xD2, alpha)
	else:
		texture_rect.texture = texture_text_not_pressed
		texture_rect.self_modulate = Color(0xFF, 0xFF, 0xFF, alpha)
	if not enable:
		texture_rect.self_modulate = Color(0x6E, 0x6E, 0x6E, alpha)
