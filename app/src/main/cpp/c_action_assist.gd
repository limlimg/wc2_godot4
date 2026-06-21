extends Node

const _CActionAssist = preload("res://app/src/main/cpp/c_action_assist.gd")

var sea_area_count: int

static func instance() -> _CActionAssist:
	return CActionAssist
