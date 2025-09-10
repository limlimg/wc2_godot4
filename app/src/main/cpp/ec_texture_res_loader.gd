@tool
class_name ecTextureResloader
extends ResourceFormatLoader

## Same as "res://app/src/main/cpp/ec_texture_loader.gd", this loader intervenes
## the loading of .xml files. It is intended for those imported as ecTextureRes,
## but they cannot be distinguished from other .xml files at runtime.
## 
## The rules for adding the suffixes are the same, except that "_hd" is added
## for high-resolution resources instead of "@2x".
## 
## Hopefully this wouldn't significantly slow down the loading of all custom
## reources.

const _HD_SUFFIX = "_hd"
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _ecTexture := preload("res://app/src/main/cpp/ec_texture.gd")
const _TextureLoader = preload("res://app/src/main/cpp/ec_texture_loader.gd")

func _init() -> void:
	ResourceLoader.add_resource_format_loader(self, true)


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["res"])


#func _handles_type(type: StringName) -> bool:
	#return type == &"Resource"
#
#
func _recognize_path(path: String, _type: StringName) -> bool:
	for ext in _get_recognized_extensions():
		if path.ends_with(ext):
			return path.contains(".xml")
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
	# return FAILED to invoke the original loader (Godot loader resolution mechanism)
	var s := original_path
	var i := s.rfind('.')
	if s.substr(i - 3, 3) == _HD_SUFFIX:
		i -= 3
		s = s.erase(i, 3)
	if s.substr(i - 5, 5) in ["_iPad", "-640h", "-568h", "-534h", "-512h"]:
		i -= 5
		s = s.erase(i, 5)
	if not Engine.is_editor_hint():
		if _native.g_content_scale_factor == 2.0:
			var path_hd = s.insert(i, _HD_SUFFIX)
			var path_suffix_hd := _TextureLoader.insert_suffix(path_hd, i)
			if path_suffix_hd == original_path:
				return FAILED
			elif ResourceLoader.exists(path_suffix_hd):
				return load(path_suffix_hd)
		var path_suffix := _TextureLoader.insert_suffix(s, i)
		if path_suffix == original_path:
			return FAILED
		elif ResourceLoader.exists(path_suffix):
			return load(path_suffix)
	if _native.g_content_scale_factor == 2.0:
		var path_hd = s.insert(i, _HD_SUFFIX)
		if path_hd == original_path:
				return FAILED
		elif ResourceLoader.exists(path_hd):
				return load(path_hd)
	return FAILED
