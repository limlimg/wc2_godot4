@tool
class_name ecUniFontAssets
extends "res://app/src/main/cpp/ec_uni_font.gd"

const _AssetNamesContentSizeHd = preload("res://app/src/main/cpp/scene_system_resource/asset_names_content_size_hd.gd")

@export
var asset_names: _AssetNamesContentSizeHd:
	set(value):
		if value != asset_names:
			if asset_names != null:
				asset_names.changed.disconnect(_assets_changed)
			asset_names = value
			_assets_changed()
			if asset_names != null:
				asset_names.changed.connect(_assets_changed)


func _assets_changed() -> void:
	release()
	var name_hd := asset_names.get_hd_name()
	if not name_hd.is_empty():
		init(name_hd, true)
	var name := asset_names.get_effective_name()
	if not name.is_empty():
		init(name, false)
	emit_changed()
