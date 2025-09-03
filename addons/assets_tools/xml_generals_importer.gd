@tool
extends EditorImportPlugin

const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")
const _GeneralPhoto = preload("res://app/src/main/cpp/imported/general_photo.gd")
const _GeneralPhotoMap = preload("res://app/src/main/cpp/imported/general_photo_map.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml.generals"


func _get_visible_name() -> String:
	return "GeneralPhotos"


func _get_format_version() -> int:
	return 1


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["xml"])


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
	var doc := _TiXmlDocument.new()
	var err := doc.load_file(source_file)
	if err != OK:
		return err
	var xml_root := doc.first_child_element("generals")
	if xml_root == null:
		push_error("Parse Error: Failed to find <generals> in {0}".format([source_file]))
		return ERR_PARSE_ERROR
	var res_generals := _GeneralPhotoMap.new()
	var xml_general := xml_root.first_child_element()
	while xml_general != null:
		var name := xml_general.attribute("name")
		if name == "":
			push_error("Parse Error: Element does not have valid \"name\" attibute on line {0} of {1}".format([xml_general.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		var res_general := GeneralPhoto.new()
		var filename := xml_general.attribute("filename")
		if filename == "":
			push_error("Parse Error: Element does not have valid \"filename\" attibute on line {0} of {1}".format([xml_general.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		var p: Array[float] = []
		if xml_general.query_float_attribute("w", p) != xml_general.TIXML_SUCCESS:
			push_error("Parse Error: Element does not have valid \"w\" attibute on line {0} of {1}".format([xml_general.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_general.w = p.pop_back()
		if xml_general.query_float_attribute("h", p) != xml_general.TIXML_SUCCESS:
			push_error("Parse Error: Element does not have valid \"h\" attibute on line {0} of {1}".format([xml_general.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_general.h = p.pop_back()
		if xml_general.query_float_attribute("refx", p) != xml_general.TIXML_SUCCESS:
			push_error("Parse Error: Element does not have valid \"refx\" attibute on line {0} of {1}".format([xml_general.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_general.refx = p.pop_back()
		res_generals.generals[name] = res_general
		xml_general = xml_general.next_sibling_element()
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res_generals, filename)
