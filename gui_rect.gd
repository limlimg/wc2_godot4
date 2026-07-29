@tool
class_name GUIRect
extends Resource

@export
var rect: Rect2:
	set(value):
		if value != rect:
			rect = value
			emit_changed()


@export
var scale := Vector2.ONE:
	set(value):
		if value != scale:
			scale = value
			emit_changed()
