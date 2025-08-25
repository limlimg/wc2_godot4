class_name ArmyDefListMap
extends Resource

const _ArmyDefList = preload("res://app/src/main/cpp/imported/army_def_list.gd")

@export
var others: _ArmyDefList

@export
var countries: Dictionary[StringName, _ArmyDefList]
