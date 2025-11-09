extends "res://app/src/main/cpp/gui_element.gd"

const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")
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
func init_texture(texture_name: String, attr: _ecTextureRect, rect: Rect2) -> bool:
	position = rect.position
	size = rect.size
	return set_image(texture_name, attr)


func init_image_attr(image_name: StringName, rect: Rect2) -> bool:
	position = rect.position
	size = rect.size
	texture = _ecImageTexture.from_ec_image_attr(_s_texture_res.get_image(image_name))
	return texture != null


func _set_alpha(value: float) -> void:
	alpha = value


## The original method has more parameter for specifying texture format.
func set_image(texture_name: String, attr: _ecTextureRect) -> bool:
	var new_image := _ecImageAttr.new()
	new_image.texture = _ecGraphics.instance().load_texture(texture_name)
	new_image.region = Rect2(attr.x, attr.y, attr.w, attr.h)
	new_image.ref = Vector2(attr.refx, attr.refy)
	texture = _ecImageTexture.from_ec_image_attr(new_image)
	return texture != null
