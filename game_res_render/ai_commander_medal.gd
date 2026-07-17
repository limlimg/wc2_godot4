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
	ecGraphics.instance().render_begin(self)
	g_GameRes.render_ai_commander_medal(stack, 0.0, 0.0, country, common)
	ecGraphics.instance().render_end()
