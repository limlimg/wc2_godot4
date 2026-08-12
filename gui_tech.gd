extends GUIElement

@export
var show_board := true:
	set(value):
		if value != show_board:
			show_board = value
			$TechnologyBoard.visible = value


var _tech: int

func _process(_delta: float) -> void:
	var country = g_GameManager.get_cur_country()
	if country != null and _tech != country.tech_level:
		_tech = country.tech_level
		var res := texture_res
		if res == null:
			res = s_texture_res
		if res != null:
			$Technology.texture = res.get_image("technology_{0}.png".format([_tech]))
