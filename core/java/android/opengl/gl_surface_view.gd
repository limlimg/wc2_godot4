extends "res://core/java/android/view/view.gd"

signal _surface_created

func set_renderer(on_surface_created: Callable, on_surface_changed: Callable, on_draw_frame: Callable) -> void:
	_surface_created.connect(on_surface_created)
	resized.connect(on_surface_changed.bind(size.x, size.y))
	draw.connect(on_draw_frame)


func _process(_delta):
	queue_redraw()
