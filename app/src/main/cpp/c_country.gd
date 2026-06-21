
const _SaveCountryInfo = preload("res://app/src/main/cpp/save_country_info.gd")

var alliance: int
var defeated: int
var money: int
var industry: int
var tax_factor: float
var id: StringName
var name: StringName
var color: Color
var ai: bool
var techlevel: int
var commander_alive: bool

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
