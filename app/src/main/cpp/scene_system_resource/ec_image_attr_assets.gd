@tool
class_name ecImageAttrAssets
extends ecImageAssets

const _ecTextureResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_texture_res_assets.gd")

@export
var name: StringName:
	set(value):
		if value != name:
			name = value
			emit_changed()


@export
var res: _ecTextureResAssets:
	set(value):
		if value != res:
			if res != null:
				res.changed.disconnect(emit_changed)
			res = value
			emit_changed()
			if res != null:
				res.changed.disconnect(emit_changed)


func get_image() -> _ecImageAttr:
	var image := res.get_res().get_image(name)
	return image
