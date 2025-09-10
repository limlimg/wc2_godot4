@tool
class_name ecTextureResloader
extends ResourceFormatLoader

## "_hd" is the high-resolution suffix of ecTextureRes resources in the same
## way "@2x" is to textures.
## 
## Hopefully this wouldn't significantly slow down the loading of all custom
## reources.

const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _ecTexture := preload("res://app/src/main/cpp/ec_texture.gd")

func _init() -> void:
	ResourceLoader.add_resource_format_loader(self, true)


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["res"])


#func _handles_type(type: StringName) -> bool:
	#return type == &"Resource"
#
#
func _recognize_path(path: String, _type: StringName) -> bool:
	if  _native.g_content_scale_factor != 2.0:
		return false
	for ext in _get_recognized_extensions():
		if path.ends_with(ext):
			var i := path.rfind('.xml')
			if i == -1:
				return false
			if path.substr(i - 3, 3) == "_hd":
				return false
			return true
	return false


#func _exists(path: String) -> bool:
	#pass
#
#
func _get_resource_type(path: String) -> String:
	if _recognize_path(path, &"Resource"):
		return "Resource"
	return ""


func _get_resource_script_class(path: String) -> String:
	if _recognize_path(path, &"Texture2D"):
		return "ecTextureRes"
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
func _load(_path: String, original_path: String, _use_sub_threads: bool, _cache_mode: int) -> Variant:
	var new_path := original_path.insert(original_path.rfind('.xml'), "_hd")
	if not ResourceLoader.exists(new_path):
		return FAILED
	return load(new_path)
