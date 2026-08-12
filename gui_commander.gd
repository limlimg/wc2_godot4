extends GUIElement

var _effect: ecEffect
var _select_medal := -1

@onready var _list := [
		$GUIWarMedal,
		$GUIWarMedal2,
		$GUIWarMedal3,
		$GUIWarMedal4,
		$GUIWarMedal5,
		$GUIWarMedal6,
		$GUICommanderMedal
	]

signal back_pressed

func init() -> void:
	if not is_node_ready():
		return
	super()
	$GUICommanderMedal.rank = g_Commander.rank
	_select_medal = -1
	_set_commander_info()


func _set_commander_info() -> void:
	if _select_medal == 6:
		var rank = g_Commander.rank + 1
		$Medal/ecText.text = "rank {0}".format([rank])
		$MedalIntro/ecText.text = "rank {0} intro".format([rank])
		if not g_Commander.is_max_level():
			$GUIUpgradeButton.visible = true
			$GUIUpgradeButton.need_medal = g_Commander.get_upgrade_medal()
		else:
			$GUIUpgradeButton.visible = false
	elif _select_medal >= 0:
		var level = g_Commander.get_war_medal_level(_select_medal)
		if level <= 0:
			level = 1
		$Medal/ecText.text = "war medal {0} level {1}".format([_select_medal + 1, level])
		$MedalIntro/ecText.text = "war medal {0} level {1} intro".format([_select_medal + 1, level])
		if level <= 2:
			$GUIUpgradeButton.visible = true
			$GUIUpgradeButton.need_medal = g_Commander.get_need_upgrade_medal(_select_medal)
		else:
			$GUIUpgradeButton.visible = false
	$GUICommanderMedal.rank = g_Commander.rank
	$GUIWarMedal.level = g_Commander.get_war_medal_level(WARMEDAL_ID.INFANTRY_MEDAL)
	$GUIWarMedal2.level = g_Commander.get_war_medal_level(WARMEDAL_ID.AIR_FORCE_MEDAL)
	$GUIWarMedal3.level = g_Commander.get_war_medal_level(WARMEDAL_ID.ARTILLERY_MEDAL)
	$GUIWarMedal4.level = g_Commander.get_war_medal_level(WARMEDAL_ID.ARMOUR_MEDAL)
	$GUIWarMedal5.level = g_Commander.get_war_medal_level(WARMEDAL_ID.NAVY_MEDAL)
	$GUIWarMedal6.level = g_Commander.get_war_medal_level(WARMEDAL_ID.COMMERCE_MEDAL)
	$GUIAdornMedal.refresh()


func _selected_medal(source: Node) -> void:
	for i in _list.size():
		_list[i].selected = _list[i] == source
		if _list[i] == source:
			_list[i].arrow_color = Color.GREEN
			_select_medal = i
	_set_commander_info()


func _on_gui_button_pressed() -> void:
	back_pressed.emit()


func _on_gui_upgrade_button_pressed() -> void:
	if _select_medal == 6:
		if g_Commander.check_upgrade():
			CSoundBox.get_instance().play_se("commander_lvup.wav")
			g_Commander.upgrade()
			g_Commander.save()
			var pos: Vector2
			if ecGraphics.instance().content_scale_size_mode == 3:
				pos = Vector2(554, 560)
			else:
				pos = Vector2(246, 244)
			if _effect != null:
				_effect.queue_free()
			_effect = $ecEffect.create_instance()
			_effect.fire_at(pos.x, pos.y, 0.0)
			_set_commander_info()
	elif g_Commander.check_upgrade_war_medal(_select_medal):
		CSoundBox.get_instance().play_se("commander_lvup.wav")
		g_Commander.upgrade_war_medal(_select_medal)
		g_Commander.save()
		var medal: Control = _list[_select_medal]
		var pos = medal.global_position - global_position + medal.size / 2
		_effect = $ecEffect.create_instance()
		_effect.fire_at(pos.x, pos.y, 0.0)
		_set_commander_info()




func _process(delta: float) -> void:
	if _effect != null:
		_effect.update(delta)
		if not _effect.is_live():
			_effect.queue_free()
			_effect = null


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
	elif event.is_action_released(&"ui_cancel"):
		back_pressed.emit()
		accept_event()
