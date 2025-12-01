@tool
class_name ecTextureAssets
extends ecImageAssets

const _AssetNamesContentSize = preload("res://app/src/main/cpp/scene_system_resource/asset_names_content_size.gd")
const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")

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


func get_image() -> _ecImageAttr:
	if name == null:
		return null
	var image: _ecImageAttr
	var selected_name := name.get_effective_name()
	if not Engine.is_editor_hint():
		var graphics := _ecGraphics.instance()
		var selected_texture := graphics.load_texture(selected_name)
		image = _ecImageAttr.new()
		image.texture = selected_texture
	else:
		var selected_path := _native.get_path_alias(selected_name, "")
		if not selected_path.is_empty():
			var selected_texture := _native.ec_texture_load(selected_path)
			image = _ecImageAttr.new()
			image.texture = selected_texture
		else: # in the editor, the situation is considered where only @2x variant exists
			selected_path = _native.get_2x_path(selected_name, "")
			if not selected_path.is_empty():
				image = _ecImageAttr.new()
				image.texture = _native.ec_texture_load(selected_path)
				image.texture.size_override = image.texture.texture.get_size() / 2.0
	if image != null:
		image.region = Rect2(Vector2.ZERO, image.texture.size_override)
		image.ref = Vector2.ZERO
	return image
