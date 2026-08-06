extends Node2D

@export
var stack: int:
	set(value):
		if value != stack:
			stack = value
			queue_redraw()


@export
var country: String:
	set(value):
		if value != country:
			country = value
			queue_redraw()


@export
var common: int:
	set(value):
		if value != common:
			common = value
			queue_redraw()


func _draw() -> void:
	g_GameRes.render_ai_commander_medal(self.get_canvas_item(), stack, 0.0, 0.0, country, common)
