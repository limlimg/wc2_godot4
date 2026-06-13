class_name AreaData
extends Resource

@export_storage
var _data: PackedInt32Array

func get_area_position(id: int) -> Vector2:
	return Vector2(_data[11 * id], _data[11 * id + 1])


func get_area_size(id: int) -> Vector2:
	return Vector2(_data[11 * id + 2], _data[11 * id + 3])


func get_army_position(id: int) -> Vector2:
	return Vector2(_data[11 * id + 4], _data[11 * id + 5])


func get_construction_position(id: int) -> Vector2:
	return Vector2(_data[11 * id + 6], _data[11 * id + 7])


func get_installation_position(id: int) -> Vector2:
	return Vector2(_data[11 * id + 8], _data[11 * id + 9])


func get_area_sea(id: int) -> int:
	return _data[11 * id + 10]
