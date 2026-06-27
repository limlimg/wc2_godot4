class_name UnitMotionsMap
extends Resource

const _UnitMotions = preload("res://app/src/main/cpp/unit_motions.gd")

@export
var units: Dictionary[String, _UnitMotions]
