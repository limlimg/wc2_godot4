@tool
extends EditorImportPlugin

const UNIT_POSITIONS_SIZE = 5
const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")
const _UnitPositions = preload("res://app/src/main/cpp/imported/unit_positions.gd")
const _UnitPositionsMap = preload("res://app/src/main/cpp/imported/unit_positions_map.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml.unitpositions"


func _get_visible_name() -> String:
	return "UnitPositions"


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
	var xml_root := doc.first_child_element("Units")
	if xml_root == null:
		push_error("Parse Error: Failed to find <Units> in {0}".format([source_file]))
		return ERR_PARSE_ERROR
	var res_units := _UnitPositionsMap.new()
	var xml_unit := xml_root.first_child_element()
	while xml_unit != null:
		var res_unit := _UnitPositions.new()
		res_unit.x.resize(UNIT_POSITIONS_SIZE)
		res_unit.y.resize(UNIT_POSITIONS_SIZE)
		res_unit.scale.resize(UNIT_POSITIONS_SIZE)
		var name := xml_unit.attribute("name")
		if name == "":
			push_error("Parse Error: Element does not have valid \"name\" attibute on line {0} of {1}".format([xml_unit.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		var xml_positions := xml_unit.first_child_element("Positions")
		var position_set: Array[bool] = []
		position_set.resize(UNIT_POSITIONS_SIZE)
		position_set.fill(false)
		if xml_positions != null:
			var xml_position := xml_positions.first_child_element()
			while xml_position != null:
				var pi: Array[int] = []
				var idx := 0
				if xml_position.query_int_attribute("idx", pi) == xml_position.TIXML_SUCCESS:
					idx = pi.pop_back()
				if idx < 0 or idx >= UNIT_POSITIONS_SIZE:
					push_error("Parse Error: Element does not have valid \"idx\" attibute on line {0} of {1}".format([xml_position.row() + 1, source_file]))
					return ERR_PARSE_ERROR
				if position_set[idx]:
					push_error("Parse Error: Replicated \"idx\" attibute on line {0} of {1}".format([xml_position.row() + 1, source_file]))
					return ERR_PARSE_ERROR
				position_set[idx] = true
				var pf: Array[float] = []
				if xml_position.query_float_attribute("x", pf) != xml_position.TIXML_SUCCESS:
					push_error("Parse Error: Element does not have valid \"x\" attibute on line {0} of {1}".format([xml_position.row() + 1, source_file]))
					return ERR_PARSE_ERROR
				res_unit.x[idx] = pf.pop_back()
				if xml_position.query_float_attribute("y", pf) != xml_position.TIXML_SUCCESS:
					push_error("Parse Error: Element does not have valid \"y\" attibute on line {0} of {1}".format([xml_position.row() + 1, source_file]))
					return ERR_PARSE_ERROR
				res_unit.y[idx] = pf.pop_back()
				if xml_position.query_float_attribute("scale", pf) != xml_position.TIXML_SUCCESS:
					push_error("Parse Error: Element does not have valid \"scale\" attibute on line {0} of {1}".format([xml_position.row() + 1, source_file]))
					return ERR_PARSE_ERROR
				res_unit.scale[idx] = pf.pop_back()
				xml_position = xml_position.next_sibling_element()
		if position_set.any(func(x): not x):
			push_error("Parse Error: <Unit> does not define five positions on line {0} of {1}".format([xml_unit.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		xml_unit = xml_unit.next_sibling_element()
		res_units.units[name] = res_unit
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res_units, filename)
