class_name CommanderDefMap
extends Resource

const _CommanderDef = preload("res://app/src/main/cpp/imported/commander_def.gd")

@export
var commanders: Dictionary[StringName, _CommanderDef]
