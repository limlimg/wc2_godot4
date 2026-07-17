extends GUIElement

signal ok_pressed
signal cancel_pressed

@export
var attack := -1:
	set(value):
		if value != attack:
			attack = value
			_set_attack(value, $AttackCountry, $UIAttackArmy)


@export
var defend := -1:
	set(value):
		if value != defend:
			defend = value
			_set_attack(value, $DefendCountry, $UIDefendArmy)


func _set_attack(area_id: int, flag: Sprite2D, ui_army) -> void:
	var area := AppDelegate.g_Scene.get_area(area_id)
	var country := area.country
	var flag_name := "flag_{0}.png".format([country.name])
	flag.texture = g_GameRes.get_flag_image(flag_name)
	var army := area.get_army(0)
	ui_army.country = country.name
	ui_army.id = army.def.id
	ui_army.durability = army.durability
	ui_army.max_durability = army.get_max_strength()
	ui_army.movement = army.movement
	ui_army.cards = army.cards
	ui_army.level = army.level if army.cards & (1 << 3) == 0 else country.get_commander_level()
	ui_army.alliance = country.alliance
	ui_army.ai = country.ai


func _on_button_ok_pressed() -> void:
	ok_pressed.emit()


func _on_button_cancel_pressed() -> void:
	cancel_pressed.emit()
