class_name ecUniFontloader
extends ResourceFormatLoader

## It g_contentscalefactor == 2.0, "_hd" suffix is added to name of the font
## file to load. If the content size is 1024x768, "num4.fnt" is a special
## exception from such suffuxing. This loader cannot tell if the font should be
## used in half the size. Use the global ecUniFont in
## "res://app/src/main/cpp/native-lib.gd" when setting font from code. The
## default size of imported fonts can be seen from its import option. Refer to
## it when setting the fone_size of ecText in the editor.

const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")

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
			if i == -1 or path.substr(i, 4) != ".fnt":
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
		return "FontFile"
	return ""


func _get_resource_script_class(_path: String) -> String:
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
	if _ecGraphics.instance().content_scale_size_mode == 3 and original_path.ends_with("num4.fnt"):
		return FAILED # The engine will try other loaders, which will load this resource as-is.
	var new_path := original_path.insert(original_path.rfind('.fnt'), "_hd")
	if not ResourceLoader.exists(new_path):
		return FAILED # The engine will try other loaders, which will load this resource as-is.
	return load(new_path)
