extends GUIElement

signal cancelled

func _on_gui_button_cancel_pressed() -> void:
	cancelled.emit()


func _on_gui_button_confirm_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
