extends GUIElement

@export
var texture_res: ecTextureRes

@export
var card: CardDef:
	set = set_card

func set_card(value: CardDef) -> void:
	if value != card:
		card = value
		$Card/TextureRect.texture = texture_res.get_image(value.image)
