@tool
class_name GUIButton
extends GUIElement

@export
var enable := true:
	get():
		return not $TextureButton.disabled
	set(value):
		if value != not $TextureButton.disabled:
			$TextureButton.disabled = not value
			_on_render()


@export
var play_sound_when_pressed := true

@export
var grey_when_pressed := false:
	set(value):
		if value != grey_when_pressed:
			grey_when_pressed = value
			_on_render()


@export_range(0.0, 1.0, 1.0/255.0)
var grey_scale := 1.0:
	set(value):
		if value != grey_scale:
			grey_scale = value
			_on_render()


@export_range(0.0, 1.0, 1.0/255.0)
var alpha := 1.0:
	set = set_alpha

@export_group("Textures", "texture_")
@export
var texture_normal: Texture2D:
	get():
		return $TextureButton.texture_normal
	set(value):
		$TextureButton.texture_normal = value


@export
var texture_pressed: Texture2D:
	get():
		return $TextureButton.texture_pressed
	set(value):
		$TextureButton.texture_pressed = value


@export
var texture_background: Texture2D:
	get():
		return $Background.texture
	set(value):
		$Background.texture = value


@export
var texture_glow: Texture2D:
	get():
		return $Glow.texture
	set(value):
		$Glow.texture = value


@export
var texture_text_image: Texture2D:
	get():
		return $TextImage.texture
	set(value):
		$TextImage.texture = value


@export_group("Text", "text_")
@export
var text: String:
	get = get_text,
	set = set_text

@export
var text_font: Theme:
	get():
		return $Label.theme
	set(value):
		$Label.theme = value


@export
var text_color := Color.WHITE:
	get = get_text_color,
	set = set_text_color

@export
var text_offset: Vector2:
	get = get_text_offset,
	set = set_text_offset

@export
var text_align: HorizontalAlignment:
	get = get_text_align,
	set = set_text_align


signal pressed

#func init(normal_image_name: StringName, pressed_image_name: StringName,
		#rect: Rect2, font: ecUniFont) -> void:
	#texture_normal = _ecImageTexture.from_ec_image_attr(s_texture_res.get_image(normal_image_name)) 
	#texture_pressed = _ecImageTexture.from_ec_image_attr(s_texture_res.get_image(pressed_image_name))
	#position = rect.position
	#size = rect.size
	##text_font = font
#
#
#func set_background(image_name: StringName) -> void:
	#texture_background = _ecImageTexture.from_ec_image_attr(s_texture_res.get_image(image_name))
#
#
#func _set_glow(image_name: StringName) -> void:
	#texture_glow = _ecImageTexture.from_ec_image_attr(s_texture_res.get_image(image_name))


func get_text() -> String:
	return $Label.text


func set_text(value: String) -> void:
	$Label.text = value


func get_text_color() -> Color:
	return $Label.get_theme_color(&"font_color")


func set_text_color(value: Color) -> void:
	$Label.remove_theme_color_override(&"font_color")
	$Label.add_theme_color_override(&"font_color", value)


func get_text_offset() -> Vector2:
	return Vector2($Label.offset_left, $Label.offset_top)


func set_text_offset(value: Vector2) -> void:
	$Label.offset_left = value.x
	$Label.offset_right = value.x
	$Label.offset_top = value.y
	$Label.offset_bottom = value.y


func get_text_align() -> HorizontalAlignment:
	return $Label.horizontal_alignment


func set_text_align(value: HorizontalAlignment) -> void:
	$Label.horizontal_alignment = value
	match value:
		HORIZONTAL_ALIGNMENT_RIGHT:
			$Label.grow_horizontal = GROW_DIRECTION_END
		HORIZONTAL_ALIGNMENT_CENTER:
			$Label.grow_horizontal = GROW_DIRECTION_BOTH
		_:
			$Label.grow_horizontal = GROW_DIRECTION_BEGIN


#func set_text_image(image_name: StringName) -> void:
	#texture_text_image = _ecImageTexture.from_ec_image_attr(s_texture_res.get_image(image_name))


func set_alpha(value: float) -> void:
	if value != alpha:
		alpha = value
		_on_render()


func _ready() -> void:
	_on_render()


func _on_render():
	if $TextureButton.button_pressed:
		$Glow.show()
		$Glow.self_modulate = Color(Color.WHITE * grey_scale, alpha)
	else:
		$Glow.hide()
	if not enable:
		var color := Color8(110, 110, 110) * grey_scale
		$TextureButton.self_modulate = Color(color, alpha)
	else:
		if grey_when_pressed and $TextureButton.button_pressed:
			var color := Color8(210, 210, 210) * grey_scale
			$TextureButton.self_modulate = Color(color, alpha)
		else:
			$TextureButton.self_modulate = Color(Color.WHITE * grey_scale, alpha)
	if grey_when_pressed and $TextureButton.button_pressed:
		var color := Color8(210, 210, 210) * grey_scale
		$TextImage.self_modulate = Color(color, alpha)
	else:
		$TextImage.self_modulate = Color(grey_scale, grey_scale, grey_scale, alpha)


func _on_texture_button_button_down() -> void:
	_on_render()


func _on_texture_button_button_up() -> void:
	_on_render()


func _on_texture_button_pressed() -> void:
	if play_sound_when_pressed:
		CSoundBox.get_instance().play_se("btn.wav")
	pressed.emit()
