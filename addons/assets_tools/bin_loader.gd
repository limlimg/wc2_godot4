@tool
extends ResourceFormatLoader

## This loader is only registered in the editor to mark the .bin files for
## export and for previewing them in the inspector. During runtime, they should
## be accessed by ecFile.

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["bin"])


func _handles_type(type: StringName) -> bool:
	return type == &"Resource"


#func _recognize_path(path: String, type: StringName) -> bool:
	#pass
#
#
#func _exists(path: String) -> bool:
	#pass
#
#
func _get_resource_type(path: String) -> String:
	return "Resource"


func _get_resource_script_class(path: String) -> String:
	if path.ends_with(".bin"):
		return "BinaryFile"
	else:
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
func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		var err := FileAccess.get_open_error()
		push_error("{0}: Failed to open {1}".format([error_string(err), path]))
		return err
	var res := BinaryFile.new()
	res.buffer = file.get_buffer(file.get_length())
	return res
