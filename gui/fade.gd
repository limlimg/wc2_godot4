extends Node2D

signal back_pressed

@export
var alpha := 0.5:
	set(value):
		alpha = value
		visible = alpha != 0
		queue_redraw()


func _ready() -> void:
	var trans_inv := get_global_transform_with_canvas().affine_inverse()
	var view_rect := get_viewport_rect()
	var v0 := trans_inv * view_rect.position
	var v1 := trans_inv * Vector2(view_rect.position.x, view_rect.end.y)
	var v2 := trans_inv * view_rect.end
	var v3 := trans_inv * Vector2(view_rect.end.x, view_rect.position.y)
	$Control.position = Vector2(min(v0.x, v1.x, v2.x, v3.x), min(v0.y, v1.y, v2.y, v3.y))
	$Control.size = Vector2(max(v0.x, v1.x, v2.x, v3.x), max(v0.y, v1.y, v2.y, v3.y)) - $Control.position


func _draw() -> void:
	ecGraphics.instance().render_begin(self)
	ecGraphics.instance().fade(alpha)
	ecGraphics.instance().render_end()


func _on_control_gui_input(event: InputEvent) -> void:
	if event.is_action(&"ui_cancel"):
		back_pressed.emit()
