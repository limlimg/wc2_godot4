extends GUIElement

signal pressed

func _on_button_pressed() -> void:
	pressed.emit()


func _gui_input(event: InputEvent) -> void:
	if event.is_action(&"ui_cancel"):
		pressed.emit()
		accept_event()
