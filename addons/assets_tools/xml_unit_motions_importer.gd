@tool
extends EditorImportPlugin

const _MOTION_TYPE = [
	"standby",
	"attack",
	"destroyed"
]
const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")
const _UnitMotion = preload("res://app/src/main/cpp/unit_motion.gd")
const _UnitMotions = preload("res://app/src/main/cpp/unit_motions.gd")
const _UnitMotionsMap = preload("res://app/src/main/cpp/imported_containers/unit_motions_map.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml.unitmotions"


func _get_visible_name() -> String:
	return "UnitMotions"


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
	var res_units := _UnitMotionsMap.new()
	var xml_unit := xml_root.first_child_element()
	while xml_unit != null:
		var res_unit := _UnitMotions.new()
		var name := xml_unit.attribute("name")
		var res := xml_unit.attribute("res")
		if res == "":
			push_error("Parse Error: Element does not have valid \"res\" attibute on line {0} of {1}".format([xml_unit.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_unit.res = res
		var pf: Array[float] = []
		var dir := 1.0
		if xml_unit.query_float_attribute("dir", pf) == xml_unit.TIXML_SUCCESS:
			dir = pf.pop_back()
		res_unit.dir = dir
		res_unit.fireeffect = xml_unit.attribute("fireeffect") # empty string allowed
		var xml_motions := xml_unit.first_child_element("Motions")
		if xml_motions != null:
			var xml_motion := xml_motions.first_child_element()
			while xml_motion != null:
				var type := _MOTION_TYPE.find(xml_motion.attribute("type"))
				if type == -1:
					type = 0
				var res_motion := _UnitMotion.new()
				var motion_name := xml_motion.attribute("name")
				if motion_name == "":
					push_error("Parse Error: Element does not have valid \"name\" attibute on line {0} of {1}".format([xml_motion.row() + 1, source_file]))
					return ERR_PARSE_ERROR
				res_motion.name = motion_name
				var at := 1.0
				if xml_motion.query_float_attribute("at", pf) == xml_motion.TIXML_SUCCESS:
					at = pf.pop_back()
				res_motion.at = at
				var pi: Array[int] = []
				var index := 0
				if xml_motion.query_int_attribute("index", pi) == xml_motion.TIXML_SUCCESS:
					index = pi.pop_back()
				res_motion.index = index
				var firex := 0.0
				if xml_motion.query_float_attribute("firex", pf) == xml_motion.TIXML_SUCCESS:
					firex = pf.pop_back()
				res_motion.firex = firex
				var firey := 0.0
				if xml_motion.query_float_attribute("firey", pf) == xml_motion.TIXML_SUCCESS:
					firey = pf.pop_back()
				res_motion.firey = firey
				if type == 1:
					res_unit.attack.append(res_motion)
				elif type == 2:
					res_unit.destroyed.append(res_motion)
				else:
					res_unit.standby.append(res_motion)
				xml_motion = xml_motion.next_sibling_element()
		res_units.units[name] = res_unit
		xml_unit = xml_unit.next_sibling_element()
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res_units, filename)
