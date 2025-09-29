extends "res://app/src/main/cpp/gui_element.gd"

const _ecTextureRect = preload("res://app/src/main/cpp/ec_texture_rect.gd")
const _ecImageAttr = preload("res://app/src/main/cpp/ec_image_attr.gd")

@export
var alpha: float:
	get():
		return $TextureRect.self_modulate.a
	set(value):
		$TextureRect.self_modulate.a = value


@export
var texture: Texture2D:
	get():
		return $TextureRect.texture
	set(value):
		$TextureRect.texture = value


## The original method has more parameters for specifying texture format.
func init_atlas(texture_name: String, attr: _ecTextureRect, rect: Rect2) -> bool:
	set_image(texture_name, attr)
	if texture == null:
		return false
	position = rect.position
	size = rect.size
	return true


func init(texture_name: String, rect: Rect2) -> bool:
	texture = _ecGraphics.instance().load_texture(texture_name)
	if texture == null:
		return false
	position = rect.position
	size = rect.size
	return true


func set_alpha(value: float) -> void:
	alpha = value


## The original method has more parameter for specifying texture format.
func set_image(texture_name: String, attr: _ecTextureRect) -> void:
	var new_texture := _ecImageAttr.new()
	new_texture.texture = _ecGraphics.instance().load_texture(texture_name)
	new_texture.region = Rect2(attr.x, attr.y, attr.w, attr.h)
	new_texture.ref = Vector2(attr.refx, attr.refy)
	texture = new_texture
