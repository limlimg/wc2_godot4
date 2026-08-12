extends Node2D

@export
var alpha := 0.5:
	set(value):
		alpha = value
		visible = alpha != 0


func _process(_delta: float) -> void:
	$Node2D.global_position = $Control.global_position
	$Node2D.queue_redraw()


func _on_node_2d_draw() -> void:
	ecGraphics.instance().render_begin($Node2D.get_canvas_item())
	ecGraphics.instance().fade(alpha)
	ecGraphics.instance().render_end()
