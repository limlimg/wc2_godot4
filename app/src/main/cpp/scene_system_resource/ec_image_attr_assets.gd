@tool
class_name ecImageAttrAssets
extends ecImageAssets

const _AssetNamesContentSize = preload("res://app/src/main/cpp/scene_system_resource/asset_names_content_size.gd")
const _ecTextureResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_texture_res_assets.gd")

@export
var name: _AssetNamesContentSize:
	set(value):
		if value != name:
			if name != null:
				name.changed.disconnect(emit_changed)
			name = value
			emit_changed()
			if name != null:
				name.changed.connect(emit_changed)


@export
var res: _ecTextureResAssets:
	set(value):
		if value != res:
			if res != null:
				res.changed.disconnect(emit_changed)
			res = value
			emit_changed()
			if res != null:
				res.changed.connect(emit_changed)


func get_image() -> _ecImageAttr:
	if res == null:
		return null
	var image := res.get_res().get_image(name.get_effective_name())
	return image
