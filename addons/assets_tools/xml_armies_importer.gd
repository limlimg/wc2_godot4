@tool
extends EditorImportPlugin

# Reference: Godot source code of resource_importer_csv_translation (https://github.com/godotengine/godot/blob/master/editor/import/resource_importer_csv_translation.cpp)

const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")

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
	var res_armies := ArmyDefListMap.new()
	var xml_armies := doc.first_child_element("armies")
	var xml_country := xml_armies.first_child_element()
	while xml_country != null:
		var res_country := ArmyDefList.new()
		var country_name := xml_country.attribute("name")
		if country_name == "others":
			res_armies.others = res_country
		else:
			res_armies.countries[country_name] = res_country
		res_country.armies.resize(ArmyDef.ARMY_TYPE.size())
		var xml_army := xml_country.first_child_element()
		while xml_army != null:
			var res_army := ArmyDef.new()
			res_army.id = ArmyDef.ARMY_TYPE.find(xml_army.attribute("type"))
			res_army.strength = xml_army.attribute("strength").to_int()
			res_army.movement = xml_army.attribute("movement").to_int()
			res_army.min_atk = xml_army.attribute("minatk").to_int()
			res_army.max_atk = xml_army.attribute("maxatk").to_int()
			res_country.armies[res_army.id] = res_army
			xml_army = xml_army.next_sibling_element()
		xml_country = xml_country.next_sibling_element()
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res_armies, filename)
