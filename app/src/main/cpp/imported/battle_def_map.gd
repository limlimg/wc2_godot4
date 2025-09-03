class_name BattleDefMap
extends Resource

const _BattleDef = preload("res://app/src/main/cpp/imported/battle_def.gd")

@export
var battlelist: Dictionary[StringName, _BattleDef]
