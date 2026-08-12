extends GUIElement

signal cancelled

func _on_gui_button_cancel_pressed() -> void:
	cancelled.emit()


func _on_gui_button_confirm_pressed() -> void:
	get_tree().root.propagate_notification.call_deferred(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
