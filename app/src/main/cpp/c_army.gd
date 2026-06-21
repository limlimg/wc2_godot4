extends Node

const _ArmyDef = preload("res://app/src/main/cpp/army_def.gd")
const _CCountry = preload("res://app/src/main/cpp/c_country.gd")

var movement: int
var cards: int
var level: int

func init(def: _ArmyDef, country: _CCountry) -> void:
	pass


func reset_max_strength(keep_ratio: bool) -> void:
	pass
