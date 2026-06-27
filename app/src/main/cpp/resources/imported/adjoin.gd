class_name Adjoin
extends Resource

@export_storage
var _index: PackedInt32Array

@export_storage
var _data: PackedInt32Array


func get_num_adjacent_areas(from_id: int) -> int:
	return _index[from_id + 1] - _index[from_id]


func get_adjacent_area_id(from_id: int, index: int) -> int:
	var head := _index[from_id]
	var tail := _index[from_id + 1]
	if index > tail - head:
		return -1
	return _data[head + index]

func check_adjacent(from: int, to: int) -> bool:
	var head := _index[from]
	var tail := _index[from + 1]
	while head < tail:
		if _data[head] == to:
			return true
		head += 1
	return false
