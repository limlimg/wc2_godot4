extends GUIElement

signal ok_pressed
signal cancel_pressed

@export
var attack := -1:
	set(value):
		if value != attack:
			attack = value
			var area = g_Scene.get_area(value)
			if area == null:
				return
			var country = area.country
			if country != null:
				$AttackCountry.texture = g_GameRes.get_flag_image("flag_{0}.png".format([country.name]))
			$UIAttackArmy.queue_redraw()


@export
var defend := -1:
	set(value):
		if value != defend:
			defend = value
			var area = g_Scene.get_area(value)
			if area == null:
				return
			var country = area.country
			if country != null:
				$DefendCountry.texture = g_GameRes.get_flag_image("flag_{0}.png".format([country.name]))
			$UIDefendArmy.queue_redraw()


func set_attack(attack_area: int, defend_area: int) -> void:
	attack = attack_area
	defend = defend_area


func _on_button_ok_pressed() -> void:
	ok_pressed.emit()


func _on_button_cancel_pressed() -> void:
	hide()
	cancel_pressed.emit()


func _on_ui_attack_army_draw() -> void:
	var area = g_Scene.get_area(attack)
	if area == null:
		return
	var army = area.get_army(0)
	if army == null:
		return
	g_GameRes.render_ui_attack_army($UIAttackArmy.get_canvas_item(), army.country.name, 0.0, 0.0, army.def.id, army.strength, army.get_max_strength(), army.movement, army.cards, army.level if army.cards & (1<<3) == 0 else army.country.get_commander_level(), army.country.alliance, army.country.ai)


func _on_ui_defend_army_draw() -> void:
	var area = g_Scene.get_area(defend)
	if area == null:
		return
	var army = area.get_army(0)
	if army == null:
		return
	g_GameRes.render_ui_defend_army($UIDefendArmy.get_canvas_item(), army.country.name, 0.0, 0.0, army.def.id, army.strength, army.get_max_strength(), army.movement, army.cards, army.level if army.cards & (1<<3) == 0 else army.country.get_commander_level(), army.country.alliance, army.country.ai)


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
	elif event.is_action_released(&"ui_cancel"):
		$ButtonCancel.pressed.emit()
		accept_event()
