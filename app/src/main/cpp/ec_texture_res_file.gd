class_name ecTextureRes
extends Resource

const _ecTextureRect = preload("res://app/src/main/cpp/ec_texture_rect.gd")

@export
var texture_name: String

@export
var texture_scale: float

@export
var images: Dictionary[StringName, _ecTextureRect]
