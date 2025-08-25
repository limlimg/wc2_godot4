@tool
extends EditorImportPlugin

const CARD_LIST_SIZE = 28
const CARD_TYPE = [
	"army",
	"navy",
	"airforce",
	"development"
]
const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")
const _CardDef = preload("res://app/src/main/cpp/imported/card_def.gd")
const _CardDefList = preload("res://app/src/main/cpp/imported/card_def_list.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml.cards"


func _get_visible_name() -> String:
	return "CardDef"


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
	var xml_cards := doc.first_child_element("cards")
	if xml_cards == null:
		push_error("Parse Error: Failed to find <cards> in {0}".format([source_file]))
		return ERR_PARSE_ERROR
	var res_cards := _CardDefList.new()
	res_cards.cards.resize(CARD_LIST_SIZE)
	var xml_card := xml_cards.first_child_element()
	while xml_card != null:
		var p: Array[int] = []
		if xml_card.query_int_attribute("id", p) != xml_card.TIXML_SUCCESS or p.back() < 0 or p.back() >= CARD_LIST_SIZE:
			print(xml_card.attribute("name"))
			print(xml_card._resource.attributes)
			push_error("Parse Error: Element does not have valid \"id\" attibute on line {0} of {1}".format([xml_card.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		var res_card := _CardDef.new()
		var id := p.pop_back()
		res_cards.cards[id] = res_card
		res_card.id = id
		var type := CARD_TYPE.find(xml_card.attribute("type"))
		if type == -1:
			type = 4
		res_card.type = type
		if xml_card.query_int_attribute("price", p) != xml_card.TIXML_SUCCESS:
			push_error("Parse Error: Element does not have valid \"price\" attibute on line {0} of {1}".format([xml_card.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_card.price = p.pop_back()
		var industry := 0
		if xml_card.query_int_attribute("industry", p) == xml_card.TIXML_SUCCESS:
			industry = p.pop_back()
		res_card.industry = industry
		var round := 1
		if xml_card.query_int_attribute("round", p) == xml_card.TIXML_SUCCESS:
			round = p.pop_back()
		res_card.round = round
		var tech := 1
		if xml_card.query_int_attribute("tech", p) == xml_card.TIXML_SUCCESS:
			tech = p.pop_back()
		res_card.tech = tech
		var name := xml_card.attribute("name")
		if name == "":
			push_error("Parse Error: Element does not have valid \"name\" attibute on line {0} of {1}".format([xml_card.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_card.name = name
		var image := xml_card.attribute("image")
		if image == "":
			push_error("Parse Error: Element does not have valid \"image\" attibute on line {0} of {1}".format([xml_card.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_card.image = image
		var intro := xml_card.attribute("intro")
		if intro == "":
			push_error("Parse Error: Element does not have valid \"intro\" attibute on line {0} of {1}".format([xml_card.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		res_card.intro = intro
		xml_card = xml_card.next_sibling_element()
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res_cards, filename)
