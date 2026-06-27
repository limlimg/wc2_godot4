@tool
extends "res://app/src/main/cpp/gui_button.gd"

const _CArmy = preload("res://app/src/main/cpp/c_army.gd")

@export
var army: _CArmy

func _process(delta: float) -> void:
	_on_update(delta)


func _on_update(_delta: float) -> void:
	if army == null or army.def == null:
		return
	var node = $Control/UIArmy
	node.country = army.country
	node.id = army.def.id
	node.durability = army.durability
	node.max_durability = army.get_max_strength()
	node.movement = army.movement
	node.cards = army.cards
	if army.cards & (1 << 3) != 0:
		node.level = army.country.get_commander_level()
	else:
		node.level = army.level
