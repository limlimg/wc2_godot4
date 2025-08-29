class_name ConquestDef
extends Resource

const _FlagInfo = preload("res://app/src/main/cpp/imported/flag_info.gd")

@export_storage
var name: StringName

@export
var centerx: float

@export
var centery: float

@export
var flag: Array[_FlagInfo]
