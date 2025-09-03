class_name UnitMotionsMap
extends Resource

const _UnitMotions = preload("res://app/src/main/cpp/imported/unit_motions.gd")

@export
var units: Dictionary[String, _UnitMotions]
