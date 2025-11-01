@tool
class_name ecImageTextureAssets
extends "res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd"
 
const _ecImageAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_image_assets.gd")

@export
var preset: _ecImageAssets:
	set(value):
		if value != preset:
			if preset != null:
				preset.changed.disconnect(_assets_changed)
			preset = value
			_assets_changed()
			if preset != null:
				preset.changed.connect(_assets_changed)


func _assets_changed() -> void:
	base_texture = null
	if preset != null:
		set_ec_image_attr(preset.get_image())
