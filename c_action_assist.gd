class_name CActionAssist
extends Node

static var _instance

var sea_area_count: int

static func instance() -> CActionAssist:
	if _instance == null:
		_instance = new()
	return _instance


static func calc_area_value(area: CArea) -> int:
	if area == null:
		return -1
	var value := 2 * area.get_real_tax() + 3 * area.get_industry()
	match area.type:
		1:
			value += 250
		2:
			value += 80
		3:
			value += 150
		4:
			value += 80
		0:
			value += 1
	match area.installation:
		1:
			value += 20
		2:
			value += 15
		3:
			value += 10
	return value
