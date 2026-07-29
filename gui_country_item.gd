extends "res://gui/gui_sel_item.gd"

@export
var country_name: String:
	set(value):
		if value != country_name:
			country_name = value
			init()


func init() -> void:
	if not is_node_ready():
		return
	super()
	var res := texture_res
	if res == null:
		res = s_texture_res
	if res == null:
		return
	var attr := res.get_image("button_%s.png"%(country_name))
	if attr != null:
		$Control/ButtonImage.texture = attr
