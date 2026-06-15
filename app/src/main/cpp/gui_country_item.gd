extends "res://app/src/main/cpp/gui_sel_item.gd"

const _ecTextureResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_texture_res_assets.gd")

@export
var country_res: _ecTextureResAssets:
	set(value):
		if value != country_res:
			country_res = value
			init()

@export
var country_name: String:
	set(value):
		if value != country_name:
			country_name = value
			init()


func init() -> void:
	super()
	if country_res == null:
		return
	var res := country_res.get_res()
	var attr := res.get_image("button_%s.png"%(country_name))
	if attr != null:
		_button_image = _ecImage.new(attr)
