class_name UnitMotions
extends Resource

const _UnitMotion = preload("res://app/src/main/cpp/unit_motion.gd")

@export
var res: StringName

@export
var fireeffect: String

@export
var dir: float

@export
var standby: Array[_UnitMotion]

@export
var attack: Array[_UnitMotion]

@export
var destroyed: Array[_UnitMotion]
