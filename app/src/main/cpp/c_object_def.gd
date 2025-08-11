extends "res://app/src/main/cpp/native-lib.gd"

const _ArmyDef = preload("res://app/src/main/cpp/imported/army_def.gd")
const _ArmyDefListMap = preload("res://app/src/main/cpp/imported/army_def_list_map.gd")

var _army_def: _ArmyDefListMap

func load_army_def() -> void:
	_army_def = load(get_path("armydef.xml", "")) as _ArmyDefListMap


func release_army_def() -> void:
	_army_def = null


func get_army_def(id: int, country: StringName) -> _ArmyDef:
	if country in _army_def.countries:
		return _army_def.countries[country].armies[id]
	else:
		return _army_def.others.armies[id]
