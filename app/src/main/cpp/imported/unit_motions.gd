class_name UnitMotions
extends Resource

const _UnitMotionList = preload("res://app/src/main/cpp/imported/unit_motion_list.gd")

@export
var res: StringName

@export
var fireeffect: String

@export
var dir: float

@export
var motions: Array[_UnitMotionList]
