extends GUIElement

@export
var medal_soldiers: int:
	set(value):
		if value != medal_soldiers:
			medal_soldiers = value
			_on_render()


@export
var medal_airforce: int:
	set(value):
		if value != medal_airforce:
			medal_airforce = value
			_on_render()


@export
var medal_cannon: int:
	set(value):
		if value != medal_cannon:
			medal_cannon = value
			_on_render()


@export
var medal_panzer: int:
	set(value):
		if value != medal_panzer:
			medal_panzer = value
			_on_render()


@export
var medal_navy: int:
	set(value):
		if value != medal_navy:
			medal_navy = value
			_on_render()


@export
var medal_honor: int:
	set(value):
		if value != medal_honor:
			medal_honor = value
			_on_render()


signal ok_pressed
signal bank_pressed

func reset_data() -> void:
	var round_text: String
	if g_GameManager.game_mode == 1:
		round_text = "ROUND {0}/{1}".format([g_GameManager.current_round + 1, g_GameManager.victory])
	else:
		round_text = "ROUND {0}".format([g_GameManager.current_round + 1])
	$Round.text = round_text
	var country = g_GameManager.get_cur_country()
	if country != null:
		$Taxes.text = "{0}".format([country.get_taxes()])
		$Industrys.text = "{0}".format([country.get_industrys()])
		if g_GameManager.game_mode == 4:
			$Sprite2D.texture = null
		$ButtonBank.visible = not country.borrowed_loan


func _process(_delta: float) -> void:
	var country = g_GameManager.get_cur_country()
	if country == null:
		return
	medal_soldiers = country.get_war_medal_level(WARMEDAL_ID.INFANTRY_MEDAL)
	medal_airforce = country.get_war_medal_level(WARMEDAL_ID.AIR_FORCE_MEDAL)
	medal_cannon = country.get_war_medal_level(WARMEDAL_ID.ARTILLERY_MEDAL)
	medal_panzer = country.get_war_medal_level(WARMEDAL_ID.ARMOUR_MEDAL)
	medal_navy = country.get_war_medal_level(WARMEDAL_ID.NAVY_MEDAL)
	medal_honor = country.get_war_medal_level(WARMEDAL_ID.COMMERCE_MEDAL)


func _on_render() -> void:
	if texture_res == null:
		return
	$MedalSoldiers/TextureRect.texture = texture_res.get_res().get_image("medal_%s_{0}.png".format([medal_soldiers]))
	$MedalAirforce/TextureRect.texture = texture_res.get_res().get_image("medal_%s_{0}.png".format([medal_airforce]))
	$MedalCannon/TextureRect.texture = texture_res.get_res().get_image("medal_%s_{0}.png".format([medal_cannon]))
	$MedalPanzer/TextureRect.texture = texture_res.get_res().get_image("medal_%s_{0}.png".format([medal_panzer]))
	$MedalNavy/TextureRect.texture = texture_res.get_res().get_image("medal_%s_{0}.png".format([medal_navy]))
	$MedalHonor/TextureRect.texture = texture_res.get_res().get_image("medal_%s_{0}.png".format([medal_honor]))


func _on_button_ok_pressed() -> void:
	hide()
	ok_pressed.emit()


func _on_button_bank_pressed() -> void:
	bank_pressed.emit()


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
	elif event.is_action_released(&"ui_cancel"):
		ok_pressed.emit()
		accept_event()
