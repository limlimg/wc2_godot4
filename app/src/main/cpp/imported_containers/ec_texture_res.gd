class_name ecTextureRes
extends Resource

## This is the imported resource of .xml files that are used to populate the
## real ecTextureRes class ("res://app/src/main/cpp/ec_texture_res.gd").

const _ecTextureRect = preload("res://app/src/main/cpp/ec_texture_rect.gd")

@export
var texture_name: String

@export
var hd: bool

@export
var images: Dictionary[StringName, _ecTextureRect]
