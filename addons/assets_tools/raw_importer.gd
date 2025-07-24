@tool
extends EditorImportPlugin

# Reference: Godot source code of Image importer (https://github.com/godotengine/godot/blob/master/editor/import/resource_importer_image.cpp)

const _CAreaMark = preload("res://app/src/main/cpp/c_area_mark.gd")

func _get_importer_name() -> String:
	return "wc2.assets.raw"


func _get_visible_name() -> String:
	return "CAreaMark"


func _get_format_version() -> int:
	return 1


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["raw"])


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
	return "Image"


func _get_save_extension() -> String:
	return "image"


func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var file := FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		var err := FileAccess.get_open_error()
		push_error("{0}: Failed to open {1}".format([error_string(err), source_file]))
		return err
	if file.get_length() < 8:
		push_error("Failed to import {0}: File too small".format([source_file]))
		return ERR_PARSE_ERROR
	var width := file.get_32()
	var height := file.get_32()
	if width == 0 or height == 0:
		push_error("Failed to import {0}: Invalid size".format([source_file]))
		return ERR_PARSE_ERROR
	if file.get_length() != 8 + 2 * width * height:
		push_error("Failed to import {0}: Unexpected file length: expected {1}, got {2}".format([source_file, 8 + 2 * width * height, file.get_length()]))
		return ERR_PARSE_ERROR
	var image_data := file.get_buffer(2 * width * height)
	var image := Image.create_empty(width, height, false, Image.FORMAT_RGB8)
	for y in height:
		for x in width:
			image.set_pixel(x, y, _CAreaMark.id_to_color(image_data.decode_u16(2 * (y * width + x))))
	var filename = save_path + "." + _get_save_extension()
	var output := FileAccess.open(filename, FileAccess.WRITE)
	if output == null:
		var err := FileAccess.get_open_error()
		push_error("Failed to import {0}: Failed to open output file {1}: {2}".format([source_file, filename, error_string(err)]))
		return err
	output.store_string("GDIM")
	output.store_pascal_string("png")
	output.store_buffer(image.save_png_to_buffer())
	return OK
