@tool
extends EditorImportPlugin

const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")
const _CommanderDef = preload("res://app/src/main/cpp/commander_def.gd")
const _CommanderDefMap = preload("res://app/src/main/cpp/imported_containers/commander_def_map.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml.commanders"


func _get_visible_name() -> String:
	return "CommanderDef"


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
	var xml_root := doc.first_child_element("commanders")
	if xml_root == null:
		push_error("Parse Error: Failed to find <commanders> in {0}".format([source_file]))
		return ERR_PARSE_ERROR
	var res_commanders := _CommanderDefMap.new()
	var xml_commander := xml_root.first_child_element()
	while xml_commander != null:
		var name := xml_commander.attribute("name")
		if name == "":
			push_error("Parse Error: Element does not have valid \"name\" attibute on line {0} of {1}".format([xml_commander.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		var res_commander := _CommanderDef.new()
		res_commander.name = name
		res_commander.country = xml_commander.attribute("country") # Does this field even have effect?
		var p: Array[int] = []
		if xml_commander.query_int_attribute("rank", p) != xml_commander.TIXML_SUCCESS:
			push_error("Parse Error: Element does not have valid \"rank\" attibute on line {0} of {1}".format([xml_commander.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_commander.rank = p.pop_back()
		var infantry := 0
		if xml_commander.query_int_attribute("infantry", p) == xml_commander.TIXML_SUCCESS:
			infantry = p.pop_back()
		res_commander.infantry = infantry
		var airforce := 0
		if xml_commander.query_int_attribute("airforce", p) == xml_commander.TIXML_SUCCESS:
			airforce = p.pop_back()
		res_commander.airforce = airforce
		var artillery := 0
		if xml_commander.query_int_attribute("artillery", p) == xml_commander.TIXML_SUCCESS:
			artillery = p.pop_back()
		res_commander.artillery = artillery
		var armour := 0
		if xml_commander.query_int_attribute("armour", p) == xml_commander.TIXML_SUCCESS:
			armour = p.pop_back()
		res_commander.armour = armour
		var navy := 0
		if xml_commander.query_int_attribute("navy", p) == xml_commander.TIXML_SUCCESS:
			navy = p.pop_back()
		res_commander.navy = navy
		var honour := 0
		if xml_commander.query_int_attribute("honour", p) == xml_commander.TIXML_SUCCESS:
			honour = p.pop_back()
		res_commander.honour = honour
		res_commanders.commanders[name] = res_commander
		xml_commander = xml_commander.next_sibling_element()
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res_commanders, filename)
