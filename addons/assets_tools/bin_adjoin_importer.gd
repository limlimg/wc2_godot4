@tool
extends EditorImportPlugin

const _Adjoin = preload("res://app/src/main/cpp/resources/imported/adjoin.gd")

func _get_importer_name() -> String:
	return "wc2.assets.bin.adjoin"


func _get_visible_name() -> String:
	return "Adjoin"


func _get_format_version() -> int:
	return 1


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["bin"])


func _get_priority() -> float:
	return 1.0


func _get_import_order() -> int:
	return 1


func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	return []


func _get_option_visibility(_path: String, _option_name: StringName, _options: Dictionary) -> bool:
	return true


func _get_preset_count() -> int:
	return 0


func _get_preset_name(preset_index: int) -> String:
	return ""


func _get_resource_type() -> String:
	return "Resource"


func _get_save_extension() -> String:
	return "res"


func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var file := FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		var err := FileAccess.get_open_error()
		push_error("{0}: Failed to open {1}".format([error_string(err), source_file]))
		return err
	if file.get_length() < 4:
		push_error("Failed to import {0}: File too small".format([source_file]))
		return ERR_PARSE_ERROR
	var size := file.get_32()
	if size == 0:
		push_error("Failed to import {0}: Invalid size".format([source_file]))
		return ERR_PARSE_ERROR
	var file_length := file.get_length()
	if file_length < 4 + 17 * 4 * size:
		push_error("Failed to import {0}: Unexpected file length: expected at least {1}, got {2}".format([source_file, 4 + 17 * 4 * size, file_length]))
		return ERR_PARSE_ERROR
	var res := _Adjoin.new()
	res.index.append(0)
	var cur := 4
	while cur < file_length:
		file.seek(cur)
		var entry_size := file.get_32()
		for i in entry_size:
			res.data.append(file.get_32())
		res.index.append(res.data.size())
		cur += 4 * max(entry_size + 1, 17)
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res, filename)
