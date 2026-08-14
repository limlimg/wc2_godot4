extends GUIElement

var _country: CCountry
var _auto_close_timer: float

signal ok_pressed

func show_defeated(country: CCountry) -> void:
	var res := texture_res
	if res == null:
		res = s_texture_res
	if res != null and country != null:
		$Flag.texture = res.get_image("flag_{0}.png".format([country.name]))
	else:
		$Flag.texture = null
	_country = country
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
	$CommanderMedal.queue_redraw()
	show()
	if g_GameManager.game_mode == 4:
		_auto_close_timer = 5.0
	g_SoundRes.play_char_se(SND_EFFECT.POP_WAV)


func hide_defeated() -> void:
	hide()


func _process(delta: float) -> void:
	if g_GameManager.game_mode == 4:
		if _auto_close_timer >= 0.0:
			_auto_close_timer -= delta
			if _auto_close_timer <= 0.0:
				_auto_close_timer = -1.0
				ok_pressed.emit()


func _on_commander_medal_draw() -> void:
	if _country.ai:
		g_GameRes.render_ai_commander_medal($WithCommander/CommanderMedal.get_canvas_item(), 1, 0.0, 0.0, _country.name, _country.alliance)
	else:
		g_GameRes.render_commander_medal($WithCommander/CommanderMedal.get_canvas_item(), 1, 0.0, 0.0, _country.get_commander_level())


func _on_button_ok_pressed() -> void:
	ok_pressed.emit()


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
	elif event.is_action_released(&"ui_cancel"):
		$ButtonOk.pressed.emit()
		accept_event()
