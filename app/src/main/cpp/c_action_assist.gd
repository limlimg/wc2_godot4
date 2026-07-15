extends Node

const _CActionAssist = preload("res://app/src/main/cpp/c_action_assist.gd")
const _CArea = preload("res://app/src/main/cpp/c_area.gd")

var sea_area_count: int

static func instance() -> _CActionAssist:
	return CActionAssist


static func calc_area_value(area: _CArea) -> int:
	if area == null:
		return -1
	var value := 2 * area.get_real_tax() + 3 * area.get_industry()
	match area.area_tax.type:
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
