extends "res://app/src/main/cpp/gui_medal_button.gd"

@export
var texture_res: _ecTextureRes:
	set(value):
		if value != texture_res:
			texture_res = value
			init()


@export
var rank: int:
	set(value):
		if value != rank:
			rank = value
			init()


func _ready() -> void:
	init()


func init() -> void:
	if texture_res != null:
		@warning_ignore("integer_division")
		var level := rank / 3 + 1
		var star := rank % 3 + 1
		var res := texture_res
		$Medal.texture = res.get_image("commander_level_{0}.png".format([level]))
		$Medal/Star.texture = res.get_image("commander_star_{0}.png".format([star]))
	else:
		$Medal.texture = null
		$Medal/Star.texture = null
