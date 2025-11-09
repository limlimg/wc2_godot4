@tool
extends "res://app/src/main/cpp/gui_element.gd"

const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")
const _ecUniFont = preload("res://app/src/main/cpp/ec_uni_font.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")

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
	set = _set_alpha


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
	set = set_text

@export
var text_font: Theme:
	get():
		return $Text.theme
	set(value):
		$Text.theme = value


@export
var text_color: Color:
	set = set_text_color

@export
var text_offset: Vector2:
	set = set_text_offset

@export
var text_align: HorizontalAlignment:
	set = set_text_align

signal pressed

func init(normal_image_name: StringName, pressed_image_name: StringName,
		rect: Rect2, font: _ecUniFont) -> void:
	texture_normal = _ecImageTexture.from_ec_image_attr(_s_texture_res.get_image(normal_image_name)) 
	texture_pressed = _ecImageTexture.from_ec_image_attr(_s_texture_res.get_image(pressed_image_name))
	position = rect.position
	size = rect.size
	text_font = font


func set_background(image_name: StringName) -> void:
	texture_background = _ecImageTexture.from_ec_image_attr(_s_texture_res.get_image(image_name))


func _set_glow(image_name: StringName) -> void:
	texture_glow = _ecImageTexture.from_ec_image_attr(_s_texture_res.get_image(image_name))


func set_text(value: String) -> void:
	$Text.text = value


func set_text_color(value: Color) -> void:
	$Text.self_modulate = value


func set_text_offset(value: Vector2) -> void:
	$Text.position = value + size / 2.0


func set_text_align(value: HorizontalAlignment) -> void:
	$Text.horizontal_alignment = value


func set_text_image(image_name: StringName) -> void:
	texture_text_image = _ecImageTexture.from_ec_image_attr(_s_texture_res.get_image(image_name))


func _set_alpha(value: float) -> void:
	if value != alpha:
		alpha = value
		_on_render()


func _ready() -> void:
	_on_render()


func _on_render():
	var _glow := $Glow
	var _texture_button := $TextureButton
	if _texture_button.button_pressed:
		_glow.show()
		_glow.self_modulate = Color(grey_scale, grey_scale, grey_scale, alpha)
	else:
		_glow.hide()
	if not enable:
		var g110 := 110.0 * grey_scale / 255.0
		_texture_button.self_modulate = Color(g110, g110, g110, alpha)
	else:
		if grey_when_pressed and _texture_button.button_pressed:
			var g210 := 210.0 * grey_scale / 255.0
			_texture_button.self_modulate = Color(g210, g210, g210, alpha)
		else:
			_texture_button.self_modulate = Color(grey_scale, grey_scale, grey_scale, alpha)
	var _text_image := $TextImage
	if grey_when_pressed and _texture_button.button_pressed:
		var g210 := 210.0 * grey_scale / 255.0
		_text_image.self_modulate = Color(g210, g210, g210, alpha)
	else:
		_text_image.self_modulate = Color(grey_scale, grey_scale, grey_scale, alpha)


func _on_texture_button_button_down() -> void:
	_on_render()


func _on_texture_button_button_up() -> void:
	_on_render()


func _on_texture_button_pressed() -> void:
	if play_sound_when_pressed:
		_CSoundBox.get_instance().play_se("btn.wav")
	pressed.emit()
