class_name ecElementData
extends Resource

const _ecItemData = preload("res://app/src/main/cpp/ec_item_data.gd")

@export
var transform: Transform2D

@export
var alpha: float

@export
var initial_frame: int

@export
var loop: int

@export
var sub_item: _ecItemData
