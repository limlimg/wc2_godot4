class_name UnitPositionsMap
extends Resource

const _UnitPositions = preload("res://app/src/main/cpp/imported/unit_positions.gd")

@export
var units: Dictionary[StringName, _UnitPositions]
