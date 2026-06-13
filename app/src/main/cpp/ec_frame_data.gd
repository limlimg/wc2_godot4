class_name ecFrameData
extends Resource

const _ecElementData = preload("res://app/src/main/cpp/ec_element_data.gd")

@export
var repeated_times: int

@export
var elements: Array[_ecElementData]
