
const _CCountry = preload("res://app/src/main/cpp/c_country.gd")
const _CArmy = preload("res://app/src/main/cpp/c_army.gd")
const _SaveAreaInfo = preload("res://app/src/main/cpp/save_area_info.gd")

@export
var army_position: Vector2


@export
var construction_position: Vector2


@export
var installation_position: Vector2


var enable: bool

@export
var sea: int

var construction: int
var level: int
var installation: int
var country: _CCountry
var army: Array[_CArmy]

func set_construction(value: int, level_value: int) -> void:
	pass


func add_army(army: _CArmy, at_bottom: bool) -> void:
	pass


func load_area(info: _SaveAreaInfo) -> void:
	pass


func get_real_tax() -> int:
	return 0


func get_industry() -> int:
	return 0


func has_army_card(card: int) -> bool:
	return false


func get_army(index: int) -> _CArmy:
	return null


func move_army_to_front(index: int, animated: bool) -> void:
	pass
