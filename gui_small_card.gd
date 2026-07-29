extends GUIElement

@export
var texture_res: ecTextureRes

@export
var card: CardDef:
	set = set_card

func set_card(value: CardDef) -> void:
	if value != card:
		card = value
		var res := texture_res
		if res == null:
			res = s_texture_res
		if res != null:
			$Card/TextureRect.texture = res.get_image(value.image)
