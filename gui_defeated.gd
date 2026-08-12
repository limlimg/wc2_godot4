extends GUIElement

var _tween_auto_close: Tween

signal ok_pressed

func show_defeated(country: CCountry) -> void:
	var res := texture_res
	if res == null:
		res = s_texture_res
	if res != null and country != null:
		$Flag.texture = res.get_image("flag_{0}.png".format([country.name]))
	else:
		$Flag.texture = null
	if country.ai:
		var commander_name := country.get_commander_name()
		if not commander_name.is_empty():
			var photo := CObjectDef.instance().get_general_photo(commander_name)
			if photo != null:
				$General.texture = res.get_image(commander_name.left(commander_name.rfind(".")) + ".png")
			else:
				$General.texture = res.get_image("general_common.png")
	else:
		$General.texture = res.get_image("general_player.png")
	show()
	if g_GameManager.game_mode == 4:
		_tween_auto_close = create_tween()
		_tween_auto_close.tween_interval(5.0)
		_tween_auto_close.tween_callback(_on_button_ok_pressed)
	g_SoundRes.play_char_se(SND_EFFECT.POP_WAV)


func hide_defeated() -> void:
	hide()
	if _tween_auto_close != null:
		_tween_auto_close.kill()
		_tween_auto_close = null


func _on_button_ok_pressed() -> void:
	ok_pressed.emit()


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
	elif event.is_action_released(&"ui_cancel"):
		ok_pressed.emit()
		accept_event()
