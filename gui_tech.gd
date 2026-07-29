extends GUIElement

@export
var texture_res: ecTextureRes

@export
var show_board := true:
	get():
		return $TechnologyBoard.visible
	set(value):
		$TechnologyBoard.visible = value


var _tech: int

func _process(delta: float) -> void:
	_on_update(delta)


func _on_update(_delta: float) -> void:
	var country := g_GameManager.get_cur_country()
	if country != null and _tech != country.tech_level:
		_tech = country.tech_level
		var res := texture_res
		if res == null:
			res = s_texture_res
		if res != null:
			$Technology.texture = res.get_image("technology_{0}.png".format([_tech]))
