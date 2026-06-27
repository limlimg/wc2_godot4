extends "res://app/src/main/cpp/gui_element.gd"

signal pressed

func _on_button_pressed() -> void:
	pressed.emit()
