
const _CCountry = preload("res://app/src/main/cpp/c_country.gd")
const _SaveCountryInfo = preload("res://app/src/main/cpp/save_country_info.gd")
const _CardDef = preload("res://app/src/main/cpp/card_def.gd")
const _CardId = preload("res://app/src/main/cpp/card_id.gd").CARD_ID
const _CountryAction = preload("res://app/src/main/cpp/country_action.gd")
const _WarMedalId = preload("res://app/src/main/cpp/war_medal_id.gd").WARMEDAL_ID

var alliance: int
var defeated: int
var money: int
var industry: int
var tax_factor: float
var id: StringName
var name: StringName
var color: Color
var ai: bool
var tech_level: int
var research_round: int
var commander_round: int
var commander_alive: bool
var borrowed_loan: bool

func init(id: StringName, name: StringName) -> void:
	pass


func set_commander(value: String) -> void:
	pass


func add_area(area_id: int) -> void:
	pass


func get_highest_value_area() -> int:
	return -1


func load_country(info: _SaveCountryInfo) -> void:
	pass


func get_commander_name() -> StringName:
	return ""


func get_commander_level() -> int:
	return 0


func can_buy_card(card: _CardDef) -> bool:
	return false


func get_card_price(card: _CardDef) -> int:
	return 0


func get_card_industry(card: _CardDef) -> int:
	return 0


func is_enough_money(card: _CardDef) -> bool:
	return false


func is_enough_industry(card: _CardDef) -> bool:
	return false


func can_use_commander() -> bool:
	return false


func get_card_rounds(card_id: _CardId) -> int:
	return 0


func set_card_targets(card: _CardDef) -> void:
	pass


func action(new_action: _CountryAction) -> void:
	pass


func get_taxes() -> int:
	return 0


func get_industrys() -> int:
	return 0


func get_war_medal_level(id: _WarMedalId) -> int:
	return 0


func use_card(card: _CardDef, area_id: int, army_index: int):
	pass


func remove_area(area_id: int) -> void:
	pass


func is_conquested() -> bool:
	return false


func be_conquested_by(conqueror: _CCountry) -> void:
	pass


func commander_die() -> void:
	pass
