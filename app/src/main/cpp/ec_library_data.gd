class_name ecLibraryData
extends Resource

const _ecMotionData = preload("res://app/src/main/cpp/imported_containers/ec_motion_data.gd")
const _ecShapeData = preload("res://app/src/main/cpp/imported_containers/ec_shape_data.gd")

@export
var motion_items: Dictionary[StringName, _ecMotionData]

@export
var shape_items: Dictionary[StringName, _ecShapeData]

@export
var frame_rate: float
