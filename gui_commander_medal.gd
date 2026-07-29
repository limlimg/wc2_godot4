@tool
extends GUIMedalButton

@export
var rank: int:
	set(value):
		if value != rank:
			rank = value
			init()


func init() -> void:
	if not is_node_ready():
		return
	super()
	var res := texture_res
	if res == null:
		res = s_texture_res
	if res != null:
		@warning_ignore("integer_division")
		var level := rank / 3 + 1
		var star := rank % 3 + 1
		$Medal.texture = res.get_image("commander_level_{0}.png".format([level]))
		$Medal/Star.texture = res.get_image("commander_star_{0}.png".format([star]))
	else:
		$Medal.texture = null
		$Medal/Star.texture = null
