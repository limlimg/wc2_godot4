extends GUIElement

signal pressed

func _on_button_pressed() -> void:
	pressed.emit()
