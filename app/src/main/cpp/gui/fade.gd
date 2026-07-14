extends Control

const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")

@export
var alpha := 0.5:
	set(value):
		alpha = value
		queue_redraw()


func _ready() -> void:
	var trans_inv := get_global_transform_with_canvas().affine_inverse()
	var view_size := get_viewport().get_visible_rect().size
	var v0 := trans_inv * Vector2.ZERO
	var v1 := trans_inv * Vector2(view_size.x, 0.0)
	var v2 := trans_inv * Vector2(view_size.x, view_size.y)
	var v3 := trans_inv * Vector2(0.0, view_size.y)
	position = Vector2(min(v0.x, v1.x, v2.x, v3.x), min(v0.y, v1.y, v2.y, v3.y))
	size = Vector2(max(v0.x, v1.x, v2.x, v3.x), max(v0.y, v1.y, v2.y, v3.y)) - position


func _draw() -> void:
	_ecGraphics.instance().render_begin(self)
	_ecGraphics.instance().fade(alpha)
	_ecGraphics.instance().render_end()
