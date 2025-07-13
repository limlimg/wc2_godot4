extends "res://core/java/android/content/context.gd"

const _View = preload("res://core/java/android/view/view.gd")

var _state := 0

func _on_create() -> void:
	pass


func _on_start() -> void:
	pass


func _on_resume() -> void:
	pass


func _on_pause() -> void:
	pass


func _on_stop() -> void:
	pass


func _on_restart() -> void:
	pass


func _on_destroy() -> void:
	pass


func _on_key_down(_key_code: int, _event: InputEvent) -> bool:
	return false


func _on_windows_focus_changed(_has_focus: bool) -> void:
	pass


func set_content_view(layoutResID: String) -> void:
	var view_res: PackedScene = load(layoutResID)
	var view := view_res.instantiate()
	add_child(view)


func find_view_by_id(id: NodePath) -> _View:
	return get_node(id)


func finish() -> void:
	queue_free()
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _enter_tree():
	if is_inside_tree():
		if _state == 0:
			_on_create()
		elif _state == 5:
			_on_restart()
		else:
			push_error("Unexpected state when entering tree: {0}".format([_state]))
			return
		_on_start()
		_on_resume()
		_state = 3


func _exit_tree():
	if _state != 0:
		if _state == 3:
			_on_pause()
		elif _state != 4:
			push_error("Unexpected state when exiting tree: {0}".format([_state]))
			return
		_on_stop()
		_state = 5


func _notification(what):
	if what == NOTIFICATION_APPLICATION_RESUMED:
		if _state == 4:
			_on_resume()
			_state = 3
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		if _state == 3:
			_on_pause()
			_state = 4
	elif what == NOTIFICATION_PREDELETE or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _state == 3:
			_on_pause()
			_on_stop()
			_on_destroy()
		elif _state == 4:
			_on_stop()
			_on_destroy()
		elif _state == 5:
			_on_destroy()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		var event := InputEventAction.new()
		event.action = &"ui_cancel"
		event.pressed = true
		Input.parse_input_event(event)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_on_windows_focus_changed(true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_on_windows_focus_changed(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		if _on_key_down(4, null):
			get_viewport().set_input_as_handled()
