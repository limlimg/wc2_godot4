extends "res://app/src/main/cpp/native-lib.gd"

const _CCamera = preload("res://app/src/main/cpp/c_camera.gd")
const _CArea = preload("res://app/src/main/cpp/c_area.gd")
const _CCountry = preload("res://app/src/main/cpp/c_country.gd")

var camera: _CCamera

func init(areas_enable: String, map: int) -> void:
	pass


func all_areas_encirclement() -> void:
	pass


func get_num_areas() -> int:
	return 0


func get_area(id: int) -> _CArea:
	return null


func set_area_country(id: int, country: _CCountry) -> void:
	pass


func set_camera_to_area(id: int) -> void:
	pass


func clear_targets() -> void:
	pass


func reset_target() -> void:
	pass
