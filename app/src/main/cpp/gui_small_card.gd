extends "res://app/src/main/cpp/gui_element.gd"

const _CardDef = preload("res://app/src/main/cpp/card_def.gd")

@export
var texture_res: _ecTextureRes

@export
var card: _CardDef:
	set = set_card

func set_card(value: _CardDef) -> void:
	if value != card:
		card = value
		$Card/TextureRect.texture = texture_res.get_image(value.image)
