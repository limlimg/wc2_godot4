@tool
extends EditorImportPlugin

const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")
const _BattleDef = preload("res://app/src/main/cpp/battle_def.gd")
const _BattleDefMap = preload("res://app/src/main/cpp/imported_containers/battle_def_map.gd")
const _FlagInfo = preload("res://app/src/main/cpp/flag_info.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml.battlelist"


func _get_visible_name() -> String:
	return "BattleDef"


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
	var xml_root := doc.first_child_element("battlelist")
	if xml_root == null:
		push_error("Parse Error: Failed to find <battlelist> in {0}".format([source_file]))
		return ERR_PARSE_ERROR
	var res_battlelist := _BattleDefMap.new()
	var xml_battle := xml_root.first_child_element()
	while xml_battle != null:
		var res_battle := _BattleDef.new()
		res_battle.greatvictory = 10
		res_battle.victory = 15
		var name := xml_battle.attribute("name")
		if name == "":
			push_error("Parse Error: Element does not have valid \"name\" attibute on line {0} of {1}".format([xml_battle.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_battle.name = name
		var age := xml_battle.attribute("age")
		if age == "":
			push_error("Parse Error: Element does not have valid \"age\" attibute on line {0} of {1}".format([xml_battle.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_battle.age = age
		var pf: Array[float] = []
		if xml_battle.query_float_attribute("centerx", pf) != xml_battle.TIXML_SUCCESS:
			push_error("Parse Error: Element does not have valid \"centerx\" attibute on line {0} of {1}".format([xml_battle.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_battle.centerx = pf.pop_back()
		if xml_battle.query_float_attribute("centery", pf) != xml_battle.TIXML_SUCCESS:
			push_error("Parse Error: Element does not have valid \"centery\" attibute on line {0} of {1}".format([xml_battle.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_battle.centery = pf.pop_back()
		if xml_battle.query_float_attribute("agex", pf) != xml_battle.TIXML_SUCCESS:
			push_error("Parse Error: Element does not have valid \"agex\" attibute on line {0} of {1}".format([xml_battle.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_battle.agex = pf.pop_back()
		if xml_battle.query_float_attribute("agey", pf) != xml_battle.TIXML_SUCCESS:
			push_error("Parse Error: Element does not have valid \"agey\" attibute on line {0} of {1}".format([xml_battle.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_battle.agey = pf.pop_back()
		var pi: Array[int] = []
		if xml_battle.query_int_attribute("victory", pi) == xml_battle.TIXML_SUCCESS:
			res_battle.victory = pi.pop_back()
		if xml_battle.query_int_attribute("greatvictory", pi) == xml_battle.TIXML_SUCCESS:
			res_battle.greatvictory = pi.pop_back()
		var xml_list := xml_battle.first_child_element()
		while xml_list != null:
			var type := xml_list.attribute("type")
			if type == "":
				push_error("Parse Error: Element does not have valid \"type\" attibute on line {0} of {1}".format([xml_list.row() + 1, source_file]))
				return ERR_PARSE_ERROR
			var xml_flag := xml_list.first_child_element()
			while xml_flag != null:
				var res_flag := _FlagInfo.new()
				res_flag.rot = 0.0
				res_flag.scale = 1.0
				var flag_name := xml_flag.attribute("name")
				if flag_name == "":
					push_error("Parse Error: Element does not have valid \"name\" attibute on line {0} of {1}".format([xml_flag.row() + 1, source_file]))
					return ERR_PARSE_ERROR
				res_flag.name = flag_name
				if xml_flag.query_float_attribute("x", pf) != xml_flag.TIXML_SUCCESS:
					push_error("Parse Error: Element does not have valid \"x\" attibute on line {0} of {1}".format([xml_flag.row() + 1, source_file]))
					return ERR_PARSE_ERROR
				res_flag.x = pf.pop_back()
				if xml_flag.query_float_attribute("y", pf) != xml_flag.TIXML_SUCCESS:
					push_error("Parse Error: Element does not have valid \"y\" attibute on line {0} of {1}".format([xml_flag.row() + 1, source_file]))
					return ERR_PARSE_ERROR
				res_flag.y = pf.pop_back()
				if xml_flag.query_float_attribute("rot", pf) == xml_flag.TIXML_SUCCESS:
					res_flag.rot = deg_to_rad(pf.pop_back())
				if xml_flag.query_float_attribute("scale", pf) == xml_flag.TIXML_SUCCESS:
					res_flag.scale = pf.pop_back()
				if type == "flag":
					res_battle.flag.append(res_flag)
				elif type == "arrow":
					res_battle.arrow.append(res_flag)
				xml_flag = xml_flag.next_sibling_element()
			xml_list = xml_list.next_sibling_element()
		res_battlelist.battlelist[name] = res_battle
		xml_battle = xml_battle.next_sibling_element()
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res_battlelist, filename)
