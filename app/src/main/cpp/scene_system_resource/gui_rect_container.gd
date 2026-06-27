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


@export
var gui_scale_ipad := Vector2.ONE:
	set(value):
		if value != gui_scale_ipad:
			gui_scale_ipad = value
			queue_sort()


@export
var gui_scale := Vector2.ONE:
	set(value):
		if value != gui_scale:
			gui_scale = value
			queue_sort()


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var selected_rect := _select_rect()
		var selected_scale := _select_scale()
		for c in get_children():
			if c is Control:
				fit_child_in_rect(c, selected_rect)
				c.scale = selected_scale


func _select_rect() -> Rect2:
	if not Engine.is_editor_hint() and _ecGraphics.instance().content_scale_size_mode == 3:
		return rect_ipad
	else:
		return rect


func _select_scale() -> Vector2:
	if not Engine.is_editor_hint() and _ecGraphics.instance().content_scale_size_mode == 3:
		return gui_scale_ipad
	else:
		return gui_scale


func _get_minimum_size() -> Vector2:
	return _select_rect().size


func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]


func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]
