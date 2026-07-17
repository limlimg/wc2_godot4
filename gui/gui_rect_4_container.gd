@tool
extends "res://gui/gui_rect_container.gd"

@export
var rect_640h: Rect2:
	set(value):
		if value != rect_640h:
			rect_640h = value
			update_minimum_size()
			queue_sort()


@export
var rect_568h: Rect2:
	set(value):
		if value != rect_568h:
			rect_568h = value
			update_minimum_size()
			queue_sort()


@export
var gui_scale_640h := Vector2.ONE:
	set(value):
		if value != gui_scale_640h:
			gui_scale_640h = value
			queue_sort()


@export
var gui_scale_568h := Vector2.ONE:
	set(value):
		if value != gui_scale_568h:
			gui_scale_568h = value
			queue_sort()


func _select_rect() -> Rect2:
	var graphics := ecGraphics.instance()
	if not Engine.is_editor_hint() and graphics.content_scale_size_mode != 3:
		if graphics.orientated_content_scale_width > 568.0:
			return rect_640h
		elif graphics.orientated_content_scale_width > 480.0:
			return rect_568h
	return super()


func _select_scale() -> Vector2:
	var graphics := ecGraphics.instance()
	if not Engine.is_editor_hint() and graphics.content_scale_size_mode != 3:
		if graphics.orientated_content_scale_width > 568.0:
			return gui_scale_640h
		elif graphics.orientated_content_scale_width > 480.0:
			return gui_scale_568h
	return super()
