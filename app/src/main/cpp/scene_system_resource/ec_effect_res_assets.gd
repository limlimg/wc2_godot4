class_name ecEffectResAssets
extends Resource

const _AssetNamesContentSize = preload("res://app/src/main/cpp/scene_system_resource/asset_names_content_size.gd")
const _ecEffectRes = preload("res://app/src/main/cpp/ec_effect_res.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")

@export
var asset_name: _AssetNamesContentSize:
	set(value):
		if value != asset_name:
			if asset_name != null:
				asset_name.changed.disconnect(_set_res_from_files)
			asset_name = value
			_set_res_from_files()
			if asset_name != null:
				asset_name.changed.connect(_set_res_from_files)

var _res := _ecEffectRes.new()

func get_res() -> _ecEffectRes:
	return _res


func _set_res_from_files() -> void:
	if asset_name == null:
		return
	var name := asset_name.get_effective_name()
	if not name.is_empty():
		_res = load(_native.get_path_alias(name, ""))
	emit_changed()
