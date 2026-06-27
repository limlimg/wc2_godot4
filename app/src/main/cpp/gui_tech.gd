extends "res://app/src/main/cpp/gui_element.gd"

@export
var texture_res: _ecTextureRes

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
	if country != null and _tech != country.techlevel:
		_tech = country.techlevel
		$Technology.texture = texture_res.get_image("technology_{0}.png".format([_tech]))
