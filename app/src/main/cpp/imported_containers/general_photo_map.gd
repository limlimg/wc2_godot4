class_name GeneralPhotoMap
extends Resource

const _GeneralPhoto = preload("res://app/src/main/cpp/general_photo.gd")

@export
var generals: Dictionary[StringName, _GeneralPhoto]
