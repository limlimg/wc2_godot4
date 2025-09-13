class_name UnitPositionsMap
extends Resource

const _UnitPositions = preload("res://app/src/main/cpp/unit_positions.gd")

@export
var units: Dictionary[StringName, _UnitPositions]
