class_name ecTextureRect
extends Resource

@export
var region: Rect2:
	set(value):
		if value != region:
			region = value
			emit_changed()


@export
var origin: Vector2:
	set(value):
		if value != origin:
			origin = value
			emit_changed()
