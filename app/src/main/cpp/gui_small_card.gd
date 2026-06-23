extends "res://app/src/main/cpp/gui_element.gd"

const _ecTextureResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_texture_res_assets.gd")
const _CardDef = preload("res://app/src/main/cpp/card_def.gd")
const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")

@export
var texture_res: _ecTextureResAssets

@export
var card: _CardDef:
	set = set_card

func set_card(value: _CardDef) -> void:
	if value != card:
		card = value
		$Card/TextureRect.texture = _ecImageTexture.from_ec_image_attr(texture_res.get_res().get_image(value.image))
