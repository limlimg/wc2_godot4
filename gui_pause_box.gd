extends GUIElement

signal resume_pressed
signal save_pressed
signal options_pressed
signal restart_pressed
signal quit_pressed

func _on_gui_button_resume_pressed() -> void:
	resume_pressed.emit()


func _on_gui_button_save_pressed() -> void:
	save_pressed.emit()


func _on_gui_button_options_pressed() -> void:
	options_pressed.emit()


func _on_gui_button_restart_pressed() -> void:
	restart_pressed.emit()


func _on_gui_button_quit_pressed() -> void:
	quit_pressed.emit()


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
