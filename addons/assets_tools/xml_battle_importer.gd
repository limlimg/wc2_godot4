@tool
extends EditorImportPlugin

const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")
const _SaveHeader = preload("res://app/src/main/cpp/save_header.gd")
const _SaveCountryInfo = preload("res://app/src/main/cpp/save_country_info.gd")
const _SaveAreaInfo = preload("res://app/src/main/cpp/save_area_info.gd")
const _SaveArmyInfo = preload("res://app/src/main/cpp/save_army_info.gd")
const _DialogueDef = preload("res://app/src/main/cpp/dialogue_def.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml.battle"


func _get_visible_name() -> String:
	return "Battle"


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
	var xml_root := doc.first_child_element("battle")
	if xml_root == null:
		push_error("Parse Error: Failed to find <battle> in {0}".format([source_file]))
		return ERR_PARSE_ERROR
	var res_battle := SaveHeader.new()
	var pi: Array[int]
	var pf: Array[float]
	var map := 1
	if xml_root.query_int_attribute("map", pi) == xml_root.TIXML_SUCCESS:
		map = pi.pop_back()
	res_battle.map = map
	res_battle.areas_enable = xml_root.attribute("areasenable")
	var xml_list := xml_root.first_child_element()
	while xml_list != null:
		match xml_list.attribute("name"):
			"country":
				var xml_country := xml_list.first_child_element()
				while xml_country != null:
					var tax_factor := 1.0
					if xml_country.query_float_attribute("taxfactor", pf) == xml_country.TIXML_SUCCESS:
						tax_factor = pf.pop_back()
					var ai := 1
					if xml_country.query_int_attribute("ai", pi) == xml_country.TIXML_SUCCESS:
						ai = pi.pop_back()
					var money := 0
					if xml_country.query_int_attribute("money", pi) == xml_country.TIXML_SUCCESS:
						money = pi.pop_back()
					var industry := 0
					if xml_country.query_int_attribute("industry", pi) == xml_country.TIXML_SUCCESS:
						industry = pi.pop_back()
					var techlevel := 1
					if xml_country.query_int_attribute("techlevel", pi) == xml_country.TIXML_SUCCESS:
						techlevel = pi.pop_back()
					var defeated := 1 if xml_country.attribute("defeated") == "army" else 0
					var alliance := 4
					match xml_country.attribute("alliance"):
						"a":
							alliance = 1
						"b":
							alliance = 2
						"c":
							alliance = 3
					var color := Color.WHITE
					if xml_country.query_int_attribute("a", pi) == xml_country.TIXML_SUCCESS:
						color.a8 = pi.pop_back()
					if xml_country.query_int_attribute("r", pi) == xml_country.TIXML_SUCCESS:
						color.r8 = pi.pop_back()
					if xml_country.query_int_attribute("g", pi) == xml_country.TIXML_SUCCESS:
						color.g8 = pi.pop_back()
					if xml_country.query_int_attribute("b", pi) == xml_country.TIXML_SUCCESS:
						color.b8 = pi.pop_back()
					var id := xml_country.attribute("id")
					var name := xml_country.attribute("name")
					var commander := xml_country.attribute("commander")
					if techlevel > 5:
						techlevel = 5
					elif techlevel <= 0:
						techlevel = 1
					var res_country := _SaveCountryInfo.new()
					res_country.money = money
					res_country.industry = industry
					res_country.techlevel = techlevel
					res_country.ai = ai
					res_country.alliance = alliance
					res_country.defeated = defeated
					res_country.id = id
					res_country.name = name
					res_country.color = color
					res_country.tax_factor = tax_factor
					res_country.commander = commander
					res_battle.country.append(res_country)
					xml_country = xml_country.next_sibling_element()
			"area":
				var xml_area := xml_list.first_child_element()
				while xml_area != null:
					var id := 0
					if xml_area.query_int_attribute("id", pi) == xml_area.TIXML_SUCCESS:
						id = pi.pop_back()
					var country := xml_area.attribute("country")
					var construction := 0
					match xml_area.attribute("construction"):
						"city":
							construction = 1
						"industry":
							construction = 2
						"airport":
							construction = 3
					var level := 0
					if xml_area.query_int_attribute("level", pi) == xml_area.TIXML_SUCCESS:
						level = pi.pop_back()
						if level < 0:
							level = 0
					var installation := 0
					match xml_area.attribute("installation"):
						"fort":
							installation = 1
						"entrenchment":
							installation = 2
						"antiaircraft":
							installation = 3
						"radar":
							installation = 4
					var res_area := _SaveAreaInfo.new()
					res_area.id = id
					res_area.construction = construction
					res_area.level = level
					res_area.installation = installation
					res_area.country = country
					var xml_army := xml_area.first_child_element()
					while xml_army != null:
						var type: int
						match xml_army.attribute("type"):
							"infantry":
								type = 0
							"panzer":
								type = 1
							"artillery":
								type = 2
							"rocket":
								type = 3
							"tank":
								type = 4
							"heavy tank":
								type = 5
							"destroyer":
								type = 6
							"cruiser":
								type = 7
							"battleship":
								type = 8
							"aircraft carrier":
								type = 9
							_:
								xml_army = xml_army.next_sibling_element()
								continue
						level = 1
						if xml_army.query_int_attribute("level", pi) == xml_army.TIXML_SUCCESS:
							level = pi.pop_back()
						var cards = 0
						if xml_army.query_int_attribute("cards", pi) == xml_army.TIXML_SUCCESS:
							cards = pi.pop_back()
						var res_army := _SaveArmyInfo.new()
						res_army.type = type
						res_army.cards = cards
						res_army.level = level
						res_area.army.append(res_army)
						xml_army = xml_army.next_sibling_element()
					res_battle.area.append(res_area)
					xml_area = xml_area.next_sibling_element()
			"dialogue":
				var xml_dialogue := xml_list.first_child_element()
				while xml_dialogue != null:
					var commander := xml_dialogue.attribute("commander")
					if xml_dialogue.query_int_attribute("index", pi) != xml_dialogue.TIXML_SUCCESS:
						push_error("Parse Error: Element does not have valid \"index\" attibute on line {0} of {1}".format([xml_dialogue.row() + 1, source_file]))
						return ERR_PARSE_ERROR
					var index := pi.pop_back()
					if xml_dialogue.query_int_attribute("atround", pi) != xml_dialogue.TIXML_SUCCESS:
						push_error("Parse Error: Element does not have valid \"atround\" attibute on line {0} of {1}".format([xml_dialogue.row() + 1, source_file]))
						return ERR_PARSE_ERROR
					var atround := pi.pop_back()
					if xml_dialogue.query_int_attribute("left", pi) != xml_dialogue.TIXML_SUCCESS:
						push_error("Parse Error: Element does not have valid \"left\" attibute on line {0} of {1}".format([xml_dialogue.row() + 1, source_file]))
						return ERR_PARSE_ERROR
					var left := 1 if pi.pop_back() != 0 else 0
					var res_dialogue := _DialogueDef.new()
					res_dialogue.commander = commander
					res_dialogue.index = index
					res_dialogue.at_round = atround
					res_dialogue.left = left
					res_battle.dialogue.append(res_dialogue)
					xml_dialogue = xml_dialogue.next_sibling_element()
			_:
				push_error("Parse Error: Unrecoginzed name on line {0} of {1}".format([xml_list.row() + 1, source_file]))
				return ERR_PARSE_ERROR
		xml_list = xml_list.next_sibling_element()
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res_battle, filename)
