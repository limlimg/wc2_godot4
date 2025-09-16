class_name ecTextureResloader
extends ResourceFormatLoader

## Add suffix when loading .xml resources in the same way as when loading
## textures, except that "_hd" is added in the place of "@2x".
## 
## Besides ecTextureRes, it is also intended to affect ecStringTable and turoial
## scripts. It also intervene the loading of other .xml resources and hopefully
## this wouldn't cause problem.

const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _ecTextureLoader = preload("res://app/src/main/cpp/loaders/ec_texture_loader.gd")
const _HD_SUFFIX = "@2x"

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
			var i := path.rfind('.', path.rfind('.') - 1)
			if i == -1 or path.substr(i, 4) != ".xml":
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
	var s := original_path
	var i := s.rfind('.')
	if s.substr(i - 3, 3) == _HD_SUFFIX:
		i -= 3
		s = s.erase(i, 3)
	if s.substr(i - 5, 5) in _ecTextureLoader.CONTENT_SIZE_SUFFIX:
		i -= 5
		s = s.erase(i, 5)
	if _native.g_content_scale_factor == 2.0:
		var path_2x = s.insert(i, _HD_SUFFIX)
		var path_suffix_2x := _ecTextureLoader.insert_suffix(path_2x, i)
		if path_suffix_2x == original_path:
			return FAILED # The engine will try other loaders, which will load this resource as-is.
		elif ResourceLoader.exists(path_suffix_2x):
			return load(path_suffix_2x)
	var path_suffix := _ecTextureLoader.insert_suffix(s, i)
	if path_suffix == original_path:
		return FAILED # The engine will try other loaders, which will load this resource as-is.
	elif ResourceLoader.exists(path_suffix):
		return load(path_suffix)
	if _native.g_content_scale_factor == 2.0:
		var path_2x = s.insert(i, _HD_SUFFIX)
		if path_2x == original_path:
				return FAILED # The engine will try other loaders, which will load this resource as-is.
		elif ResourceLoader.exists(path_2x):
				return load(path_2x)
	return FAILED # The engine will try other loaders, which will load this resource as-is.
