extends "res://core/java/android/view/view.gd"

func set_renderer(on_surface_created: Callable, on_surface_changed: Callable, on_draw_frame: Callable) -> void:
	ready.connect(on_surface_created)
	resized.connect(on_surface_changed.bind(size.x, size.y))
	draw.connect(on_draw_frame)


func _process(_delta):
	queue_redraw()
