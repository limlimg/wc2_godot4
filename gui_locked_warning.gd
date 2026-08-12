extends GUIElement

signal pressed

func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if event is InputEventScreenTouch:
			if not event.pressed:
				pressed.emit()
		accept_event()
	elif event.is_action_released(&"ui_cancel"):
		pressed.emit()
		accept_event()
