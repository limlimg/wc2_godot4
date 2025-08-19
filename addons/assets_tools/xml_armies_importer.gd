@tool
extends EditorImportPlugin

# Reference: Godot source code of resource_importer_csv_translation (https://github.com/godotengine/godot/blob/master/editor/import/resource_importer_csv_translation.cpp)

const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")
const _ArmyDef = preload("res://app/src/main/cpp/imported/army_def.gd")
const _ArmyDefList = preload("res://app/src/main/cpp/imported/army_def_list.gd")
const _ArmyDefListMap = preload("res://app/src/main/cpp/imported/army_def_list_map.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml.armies"


func _get_visible_name() -> String:
	return "ArmyDef"


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
	var xml_armies := doc.first_child_element("armies")
	if xml_armies == null:
		push_error("Parse Error: Failed to find <armies> in {0}".format([source_file]))
		return ERR_PARSE_ERROR
	var res_armies := _ArmyDefListMap.new()
	var xml_country := xml_armies.first_child_element()
	while xml_country != null:
		var country_name := xml_country.attribute("name")
		if country_name == "":
			push_error("Parse Error: Element does not have valid \"name\" attibute on line {0} of {1}".format([xml_country.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		var res_country := _ArmyDefList.new()
		res_country.armies.resize(_ArmyDef.ARMY_TYPE.size())
		var xml_army := xml_country.first_child_element()
		while xml_army != null:
			var res_army := _ArmyDef.new()
			res_army.id = _ArmyDef.ARMY_TYPE.find(xml_army.attribute("type"))
			if res_army.id == -1:
				push_error("Parse Error: Element does not have valid \"type\" attibute on line {0} of {1}".format([xml_country.row() + 1, source_file]))
				return ERR_PARSE_ERROR
			var p: Array[int]
			if xml_army.query_int_attribute("strength", p) != xml_army.TIXML_SUCCESS:
				push_error("Parse Error: Element does not have valid \"strength\" attibute on line {0} of {1}".format([xml_country.row() + 1, source_file]))
				return ERR_PARSE_ERROR
			res_army.strength = p.pop_back()
			if xml_army.query_int_attribute("movement", p) != xml_army.TIXML_SUCCESS:
				push_error("Parse Error: Element does not have valid \"movement\" attibute on line {0} of {1}".format([xml_country.row() + 1, source_file]))
				return ERR_PARSE_ERROR
			res_army.movement = p.pop_back()
			if xml_army.query_int_attribute("minatk", p) != xml_army.TIXML_SUCCESS:
				push_error("Parse Error: Element does not have valid \"minatk\" attibute on line {0} of {1}".format([xml_country.row() + 1, source_file]))
				return ERR_PARSE_ERROR
			res_army.min_atk = p.pop_back()
			if xml_army.query_int_attribute("maxatk", p) != xml_army.TIXML_SUCCESS:
				push_error("Parse Error: Element does not have valid \"maxatk\" attibute on line {0} of {1}".format([xml_country.row() + 1, source_file]))
				return ERR_PARSE_ERROR
			res_army.max_atk = p.pop_back()
			res_country.armies[res_army.id] = res_army
			xml_army = xml_army.next_sibling_element()
		if country_name == "others":
			res_armies.others = res_country
		else:
			res_armies.countries[country_name] = res_country
		xml_country = xml_country.next_sibling_element()
	if res_armies.others == null:
		push_error("Parse Error: Couldn't find default (\"others\") army data in {0}".format([source_file]))
		return ERR_PARSE_ERROR
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res_armies, filename)
