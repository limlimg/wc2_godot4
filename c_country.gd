class_name CCountry

var alliance: int
var defeated: int
var _area_list: PackedInt32Array
var _capital_list: PackedInt32Array
var money: int
var industry: int
var tax_factor: float
var id: StringName
var name: StringName
var color: Color
var ai: bool
var _conquested: bool
var tech_level: int
var research_round: int
var _card_round: PackedInt32Array
var _destroy_count: PackedInt32Array
var commander_def: CommanderDef
var commander_round: int
var commander_alive: bool
var _war_medal: PackedInt32Array
var borrowed_loan: bool

func init(init_id: StringName, init_name: StringName) -> void:
	_area_list.clear()
	_capital_list.clear()
	id = init_id
	name = init_name
	commander_round = 0
	commander_alive = false
	commander_def = null
	money = 0
	industry = 0
	research_round = 0
	defeated = 0
	_conquested = false
	borrowed_loan = false
	tech_level = 1
	ai = true
	color = Color.WHITE
	_card_round.resize(28)
	for i in 28:
		_card_round[i] = CObjectDef.instance().get_card_def(i).round
	_war_medal.resize(6)
	_war_medal.fill(0)
	_destroy_count.resize(10)
	_destroy_count.fill(0)
	tax_factor = 1.0


func remove_area(area_id: int) -> void:
	_area_list.erase(area_id)
	if AppDelegate.g_Scene.get_area(area_id).area_tax.type == 1:
		_capital_list.erase(area_id)


func add_area(area_id: int) -> void:
	if _find_area(area_id):
		return
	_area_list.append(area_id)
	if AppDelegate.g_Scene.get_area(area_id).type == 1:
		_capital_list.append(area_id)


func _find_area(area_id: int) -> bool:
	return _area_list.find(area_id) != -1


func get_highest_value_area() -> int:
	var max_id := -1
	var max_value := 0
	for i in _area_list:
		var area = AppDelegate.g_Scene.get_area(i)
		if area.has_army_card(3):
			return i
		var value := CActionAssist.calc_area_value(area)
		if value > max_value:
			max_value = value
			max_id = i
	return max_id


func _get_first_capital() -> int:
	if _capital_list.is_empty():
		return -1
	return _capital_list[0]


func is_conquested() -> bool:
	for i in _area_list:
		var area = AppDelegate.g_Scene.get_area(i)
		if not area.area_data.sea:
			return false
		if defeated == 1 and area.get_num_armies() > 0:
			return false
	return true


func _find_adjacent_area_id(id: int, has_army: bool) -> int:
	for i in AppDelegate.g_Scene.get_num_adjacent_areas(id):
		var area
	return -1


func set_commander(value: String) -> void:
	pass


func load_country(info: SaveCountryInfo) -> void:
	pass


func get_commander_name() -> StringName:
	return ""


func get_commander_level() -> int:
	return 0


func can_buy_card(card: CardDef) -> bool:
	return false


func get_card_price(card: CardDef) -> int:
	return 0


func get_card_industry(card: CardDef) -> int:
	return 0


func is_enough_money(card: CardDef) -> bool:
	return false


func is_enough_industry(card: CardDef) -> bool:
	return false


func can_use_commander() -> bool:
	return false


func get_card_rounds(card_id: CARD_ID) -> int:
	return 0


func set_card_targets(card: CardDef) -> void:
	pass


func action(new_action: CountryAction) -> void:
	pass


func get_taxes() -> int:
	return 0


func get_industrys() -> int:
	return 0


func get_war_medal_level(id: int) -> int:
	return 0


func use_card(card: CardDef, area_id: int, army_index: int):
	pass


func be_conquested_by(conqueror: CCountry) -> void:
	pass


func commander_die() -> void:
	pass
