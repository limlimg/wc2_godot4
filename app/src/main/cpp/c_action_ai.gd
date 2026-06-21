extends Node

const _CActionAI = preload("res://app/src/main/cpp/c_action_ai.gd")

var ai_progress_percentage: int
var ai_area_with_army_count: int

static func instance() -> _CActionAI:
	return CActionAI
