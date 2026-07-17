extends Node2D

@export
var alpha := 0.5:
	set(value):
		alpha = value
		visible = alpha != 0
		queue_redraw()


func _draw() -> void:
	ecGraphics.instance().render_begin(self)
	ecGraphics.instance().fade(alpha)
	ecGraphics.instance().render_end()
