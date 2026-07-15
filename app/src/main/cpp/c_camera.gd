extends SubViewport

@export
var scene_rect: Rect2:
	set(value):
		if value != scene_rect:
			scene_rect = value
			init()


func init() -> void:
	pass


func set_pos(x: float, y: float, allow_box: bool) -> void:
	pass
