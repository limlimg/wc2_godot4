extends Node2D

@export
var stack: int:
	set(value):
		if value != stack:
			stack = value
			queue_redraw()


@export
var commander_level: int:
	set(value):
		if value != commander_level:
			commander_level = value
			queue_redraw()


func _draw() -> void:
	ecGraphics.instance().render_begin(self)
	g_GameRes.render_commander_medal(stack, 0.0, 0.0, commander_level)
	ecGraphics.instance().render_end()
