extends TextureRect

const _CCountry = preload("res://app/src/main/cpp/c_country.gd")
const _CArmy = preload("res://app/src/main/cpp/c_army.gd")
const _SaveAreaInfo = preload("res://app/src/main/cpp/save_area_info.gd")

@export
var army_position: Vector2:
	get():
		return $Army.position
	set(value):
		$Army.position = value


@export
var construction_position: Vector2:
	get():
		return $Flag.position
	set(value):
		$Flag.position = value


@export
var installation_position: Vector2:
	get():
		return $Installation.position
	set(value):
		$Installation.position = value


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
