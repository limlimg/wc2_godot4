@tool
extends Container

const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")

@export
var rect_ipad: Rect2:
	set(value):
		if value != rect_ipad:
			rect_ipad = value
			update_minimum_size()
			queue_sort()

@export
var rect: Rect2:
	set(value):
		if value != rect:
			rect = value
			update_minimum_size()
			queue_sort()

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var graphics := _ecGraphics.instance()
		var selected_rect: Rect2
		if not Engine.is_editor_hint() and graphics.content_scale_size_mode == 3:
			selected_rect = rect_ipad
		else:
			selected_rect = rect
		for c in get_children():
			if c is Control:
				fit_child_in_rect(c, selected_rect)


func _get_minimum_size() -> Vector2:
	var graphics := _ecGraphics.instance()
	if not Engine.is_editor_hint() and graphics.content_scale_size_mode == 3:
		return rect_ipad.size
	else:
		return rect.size


func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return [SIZE_FILL]


func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return [SIZE_FILL]
