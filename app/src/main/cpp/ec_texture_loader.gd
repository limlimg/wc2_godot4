@tool
class_name ecTextureloader
extends ResourceFormatLoader

const _ecTexture := preload("res://app/src/main/cpp/ec_texture.gd")

func _init() -> void:
	ResourceLoader.add_resource_format_loader(self, true)
	if OS.has_feature("editor"):
		var PkmLoader := load("res://addons/assets_tools/pkm_loader.gd")
		PkmLoader.new().add_format_loader()
		var PvrLoader := load("res://addons/assets_tools/pvr_loader.gd")
		PvrLoader.new().add_format_loader()


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["png", "pvr", "pkm", "webp"])


func _handles_type(type: StringName) -> bool:
	return type == &"Texture2D"


func _recognize_path(path: String, _type: StringName) -> bool:
	for ext in _get_recognized_extensions():
		if path.ends_with(ext):
			return path.substr(path.rfind(".") - 3, 3) == "@2x"
	return false


#func _exists(path: String) -> bool:
	#pass
#
#
func _get_resource_type(path: String) -> String:
	if _recognize_path(path, &"Texture2D"):
		return "Texture2D"
	return ""


func _get_resource_script_class(path: String) -> String:
	if _recognize_path(path, &"Texture2D"):
		return "ecTexture"
	return ""


#func _get_dependencies(path: String, add_types: bool) -> PackedStringArray:
	#pass
#
#
#func _get_classes_used(path: String) -> PackedStringArray:
	#pass
#
#
#func _get_resource_uid(path: String) -> int:
	#pass
#
#
#func _rename_dependencies(path: String, renames: Dictionary) -> Error:
	#pass
#
#
func _load(path: String, original_path: String, _use_sub_threads: bool, _cache_mode: int) -> Variant:
	var texture := _ecTexture.new()
	if path.ends_with(".ctex"):
		texture.texture = CompressedTexture2D.new()
		var err: Error = texture.texture.load(path)
		if err != OK:
			return err
	else:
		var image := Image.load_from_file(path)
		push_warning("Please ignore the previous warning about loading image file.")
		texture.texture = ImageTexture.create_from_image(image)
	if original_path.substr(original_path.rfind(".") - 3, 3) == "@2x":
		texture.size_override = texture.texture.get_size() / 2
	else:
		texture.size_override = texture.texture.get_size()
	return texture
