extends GUIElement

var _fade: float

func _process(delta: float) -> void:
	_fade += 2.5 * delta
	if _fade > 0.5:
		var a := 2.0 * (_fade - 0.5)
		$GUIElement/TextureRect.self_modulate = Color(a, a, a, a)


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_released(&"ui_cancel"):
		accept_event()
