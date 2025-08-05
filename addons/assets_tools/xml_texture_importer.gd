@tool
extends EditorImportPlugin

# Reference: Godot source code of resource_importer_csv_translation (https://github.com/godotengine/godot/blob/master/editor/import/resource_importer_csv_translation.cpp)

const _XmlImporter = preload("res://addons/assets_tools/xml_importer.gd")
const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml.plist"


func _get_visible_name() -> String:
	return "Translation"


func _get_format_version() -> int:
	return 1


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["xml", "strings"])


func _get_priority() -> float:
	return 1.0


func _get_import_order() -> int:
	return 1


func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	var locale: String
	if path.contains("English.lproj/") or path.contains("_en"):
		locale = "en"
	elif path.contains("ja.lproj/") or path.contains("_ja"):
		locale = "ja"
	elif path.contains("kr.lproj/") or path.contains("_kr"):
		locale = "ko"
	elif path.contains("ru.lproj/") or path.contains("_ru"):
		locale = "ru"
	elif path.contains("zh_CN.lproj/") or path.contains("_cn"):
		locale = "zh_Hans"
	elif path.contains("zh_TW.lproj/") or path.contains("_tw"):
		locale = "zh_Hant"
	return [{
		"name": "locale",
		"default_value": locale,
		"hint_string": PROPERTY_HINT_LOCALE_ID
	}]


func _get_option_visibility(_path: String, _option_name: StringName, _options: Dictionary) -> bool:
	return true


func _get_preset_count() -> int:
	return 0


func _get_preset_name(preset_index: int) -> String:
	return ""


func _get_resource_type() -> String:
	return "Translation"


func _get_save_extension() -> String:
	return "translation"


func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var xml = _XmlImporter.static_load(source_file)
	if xml is not XML:
		return xml
	var doc := _TiXmlDocument.new()
	if not doc.load_resource(xml):
		push_error("{0} is empty".format([source_file]))
		return FAILED
	var root := doc.root_element()
	if root == null or root.value() != "plist":
		push_error("{0}: Expected root node of type <plist> in {1}".format([error_string(ERR_PARSE_ERROR), source_file]))
		return ERR_PARSE_ERROR
	var dict := root.first_child_element("dict")
	if dict == null:
		push_error("{0}: First child of <plist> should be <dict> in {1}".format([error_string(ERR_PARSE_ERROR), source_file]))
		return ERR_PARSE_ERROR
	var transltion := Translation.new()
	transltion.locale = options["locale"]
	var node := dict.first_child_element()
	while node != null:
		var key := node.get_text()
		if key == "":
			push_error("{0}: Node at line {1} should contain a text child as key in {2}".format([error_string(ERR_PARSE_ERROR), node.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		var last_node_row := node.row() + 1
		node = node.next_sibling_element()
		if node == null:
			push_error("{0}: Node at line {1} should be followed by a node containing string in {2}".format([error_string(ERR_PARSE_ERROR), last_node_row, source_file]))
			return ERR_PARSE_ERROR
		var value := node.get_text()
		if value == "":
			push_error("{0}: Node at line {1} should contain a text child as string in {2}".format([error_string(ERR_PARSE_ERROR), node.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		transltion.add_message(key, value.c_unescape())
		node = node.next_sibling_element()
	var ot := OptimizedTranslation.new()
	ot.generate(transltion)
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(ot, filename)
