@tool
extends EditorImportPlugin

const _AreaDataList = preload("res://app/src/main/cpp/imported_containers/area_data_list.gd")
const _AreaData = preload("res://app/src/main/cpp/imported_containers/area_data.gd")

func _get_importer_name() -> String:
	return "wc2.assets.bin.area"


func _get_visible_name() -> String:
	return "AreaData"


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
	if file.get_length() != 4 + 4 * 11 * size:
		push_error("Failed to import {0}: Unexpected file length: expected {1}, got {2}".format([source_file, 4 + 4 * 11 * size, file.get_length()]))
		return ERR_PARSE_ERROR
	var res := _AreaDataList.new()
	var buf = file.get_buffer(4 * 11 * size)
	for i in size:
		var data := _AreaData.new()
		data._mem = buf
		data._offset = 4 * 11 * i
		res.data.append(data)
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res, filename)
