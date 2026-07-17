class_name CActionAI
extends Node

static var _instance

var ai_progress_percentage: int
var ai_area_with_army_count: int

static func instance() -> CActionAI:
	if _instance == null:
		_instance = new()
	return _instance
