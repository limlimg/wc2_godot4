extends "res://gui/gui_sel_item.gd"

@export
var country_name: String:
	set(value):
		if value != country_name:
			country_name = value
			init()


func init() -> void:
	super()
	if texture_res == null:
		return
	var res := texture_res
	var attr := res.get_image("button_%s.png"%(country_name))
	if attr != null:
		$Control/ButtonImage.texture = attr
