@tool
extends EditorImportPlugin

const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml.script"


func _get_visible_name() -> String:
	return "TutorialScript"


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
	var xml_root := doc.first_child_element("script")
	if xml_root == null:
		push_error("Parse Error: Failed to find <script> in {0}".format([source_file]))
		return ERR_PARSE_ERROR
	var res_script := TutorialCmdList.new()
	var xml_cmd := xml_root.first_child_element()
	while xml_cmd != null:
		var res_cmd := TutorialCmd.new()
		res_cmd.name = xml_cmd.attribute("name")
		var pi: Array[int] = []
		var pf: Array[float] = []
		if xml_cmd.query_int_attribute("id", pi) == xml_cmd.TIXML_SUCCESS:
			res_cmd.id = pi.pop_back()
		if xml_cmd.query_float_attribute("x", pf) == xml_cmd.TIXML_SUCCESS:
			res_cmd.x = pf.pop_back()
		if xml_cmd.query_float_attribute("y", pf) == xml_cmd.TIXML_SUCCESS:
			res_cmd.y = pf.pop_back()
		if xml_cmd.query_float_attribute("w", pf) == xml_cmd.TIXML_SUCCESS:
			res_cmd.w = pf.pop_back()
		if xml_cmd.query_float_attribute("h", pf) == xml_cmd.TIXML_SUCCESS:
			res_cmd.h = pf.pop_back()
		res_cmd.string = xml_cmd.attribute("string")
		res_script.tutorial_script.append(res_cmd)
		xml_cmd = xml_cmd.next_sibling_element()
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res_script, filename)
