class_name ecFrameData
extends Resource

const _ecElementData = preload("res://app/src/main/cpp/ec_element_data.gd")

@export
var start_tick: int

@export
var elements: Array[_ecElementData]
