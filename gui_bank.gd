extends GUIElement

signal back_pressed

func _on_gui_button_industry_10_pressed() -> void:
	if g_Commander.medal < 1:
		return
	var country = g_GameManager.get_cur_country()
	if country == null:
		return
	g_Commander.medal -= 1
	country.industry += 6
	country.borrowed_loan = true
	CSoundBox.get_instance().play_se("buy.wav")


func _on_gui_button_industry_50_pressed() -> void:
	if g_Commander.medal < 5:
		return
	var country = g_GameManager.get_cur_country()
	if country == null:
		return
	g_Commander.medal -= 5
	country.industry += 30
	country.borrowed_loan = true
	CSoundBox.get_instance().play_se("buy.wav")


func _on_gui_button_money_20_pressed() -> void:
	if g_Commander.medal < 1:
		return
	var country = g_GameManager.get_cur_country()
	if country == null:
		return
	g_Commander.medal -= 1
	country.money += 12
	country.borrowed_loan = true
	CSoundBox.get_instance().play_se("buy.wav")


func _on_gui_button_money_100_pressed() -> void:
	if g_Commander.medal < 5:
		return
	var country = g_GameManager.get_cur_country()
	if country == null:
		return
	g_Commander.medal -= 5
	country.money += 60
	country.borrowed_loan = true
	CSoundBox.get_instance().play_se("buy.wav")


func _on_button_back_pressed() -> void:
	back_pressed.emit()


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
	elif event.is_action_released(&"ui_cancel"):
		$ButtonBack.pressed.emit()
		accept_event()
