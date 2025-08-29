class_name ConquestDefMap
extends Resource

const _ConquestDef = preload("res://app/src/main/cpp/imported/conquest_def.gd")

@export
var battlelist: Dictionary[StringName, _ConquestDef]
