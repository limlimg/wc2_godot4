extends GUIElement

signal closed

func init() -> void:
	if not is_node_ready():
		return
	super()
	$Music.set_scroll_pos(g_GameSettings.music_volume)
	$SFX.set_scroll_pos(g_GameSettings.se_volume)
	$AnimationButton.visible = not g_GameSettings.battle_animation
	$AnimationCheck.visible = g_GameSettings.battle_animation
	$GameSpeed.value = g_GameSettings.speed


func _on_gui_button_back_pressed() -> void:
	closed.emit()


func _on_gui_button_ok_pressed() -> void:
	var sound := CSoundBox.get_instance()
	var music = $Music.scroll_pos
	sound.set_music_volume(music)
	g_GameSettings.music_volume = music
	var se = $SFX.scroll_pos
	sound.set_se_volume(se)
	g_GameSettings.se_volume = se
	g_GameSettings.battle_animation = $AnimationCheck.visible
	g_GameSettings.speed = $GameSpeed.value
	g_GameSettings.save_settings()
	closed.emit()


func _set_animation(value: bool) -> void:
	$AnimationButton.visible = not value
	$AnimationCheck.visible = value


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
	elif event.is_action_released(&"ui_cancel"):
		$ButtonBack.pressed.emit()
		accept_event()
