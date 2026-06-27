class_name BattleDefMap
extends Resource

const _BattleDef = preload("res://app/src/main/cpp/battle_def.gd")

@export
var battlelist: Dictionary[StringName, _BattleDef]
