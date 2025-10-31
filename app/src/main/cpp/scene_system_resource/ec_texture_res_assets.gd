@tool
class_name ecTextureResAssets
extends Resource

const _AssetNamesContentSizeHd = preload("res://app/src/main/cpp/scene_system_resource/asset_names_content_size_hd.gd")
const _ecTextureRes = preload("res://app/src/main/cpp/ec_texture_res.gd")

@export
var asset_names: Array[_AssetNamesContentSizeHd]:
	set(value):
		if value != asset_names:
			for i in asset_names:
				if i != null:
					i.changed.disconnect(_set_res_from_files)
			asset_names = value
			_set_res_from_files()
			for i in asset_names:
				if i != null:
					i.changed.connect(_set_res_from_files)


var _res := _ecTextureRes.new()

func get_res() -> _ecTextureRes:
	return _res


func _set_res_from_files() -> void:
	_res.release()
	for i in asset_names:
		if i == null:
			continue
		var name_hd := i.get_hd_name()
		if not name_hd.is_empty():
			_res.load_res(name_hd, true)
		var name := i.get_effective_name()
		if not name.is_empty():
			_res.load_res(name, false)
	emit_changed()
