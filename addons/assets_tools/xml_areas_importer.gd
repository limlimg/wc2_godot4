@tool
extends EditorImportPlugin

const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")
const _AreaTax = preload("res://resources/imported/area_tax.gd")
const _AreaTaxMap = preload("res://resources/imported/area_tax_map.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml.areas"


func _get_visible_name() -> String:
	return "AreaTax"


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
	var xml_root := doc.first_child_element("areas")
	if xml_root == null:
		push_error("Parse Error: Failed to find <areas> in {0}".format([source_file]))
		return ERR_PARSE_ERROR
	var res_areas := _AreaTaxMap.new()
	var xml_area := xml_root.first_child_element()
	while xml_area != null:
		var type := 0
		match xml_area.attribute("type"):
			"capital":
				type = 1
			"port":
				type = 2
			"large city":
				type = 3
			"normal city":
				type = 4
		var id := 0
		var p: Array[int] = []
		if xml_area.query_int_attribute("id", p) == xml_area.TIXML_SUCCESS:
			id = p.pop_back()
		if xml_area.query_int_attribute("tax", p) != xml_area.TIXML_SUCCESS:
			push_error("Parse Error: Element does not have valid \"tax\" attibute on line {0} of {1}".format([xml_area.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		var tax := p.pop_back()
		var res_area := _AreaTax.new()
		res_area.id = id
		res_area.type = type
		res_area.tax = tax
		res_areas.areas[id] = res_area
		xml_area = xml_area.next_sibling_element()
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res_areas, filename)
