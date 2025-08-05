@tool
extends EditorImportPlugin

## Curiously, unlike .bin files, .xml files are not marked for export by a
## loader (probably because it is recognized as a text file within the engine).
## Neither does a loader instruct the engine to scan .xml files for syntax
## errors. The downside of defining an importer is that it stops the editor
## from opening .xml files inside the script editor.

const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml"


func _get_visible_name() -> String:
	return "XML"


func _get_format_version() -> int:
	return 1


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["xml", "strings"])


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
	return "tres"


func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var doc := _TiXmlDocument.new()
	var err := doc.load_file(source_file)
	if err != OK:
		return err
	var xml := XML.new()
	xml.nodes = doc._children_resrouce
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(xml, filename)
