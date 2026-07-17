extends GUIElement

var _select_medal := -1

@onready var _list := [
		$WarMedal/GUIWarMedal,
		$WarMedal2/GUIWarMedal,
		$WarMedal3/GUIWarMedal,
		$WarMedal4/GUIWarMedal,
		$WarMedal5/GUIWarMedal,
		$WarMedal6/GUIWarMedal,
		$CommanderMedal/GUICommanderMedal
	]

func _ready() -> void:
	init()


func init() -> void:
	$CommanderMedal/GUICommanderMedal.rank = g_Commander.rank
	_select_medal = -1
	_set_commander_info()


func _set_commander_info() -> void:
	if _select_medal == 6:
		var rank := g_Commander.rank + 1
		$Medal/Label.text = "rank {0}".format([rank])
		$MedalIntro/Label.text = "rank {0} intro".format([rank])
		if not g_Commander.is_max_level():
			$UpgradeButton/GUIUpgradeButton.visible = true
			$UpgradeButton/GUIUpgradeButton.need_medal = g_Commander.get_upgrade_medal()
		else:
			$UpgradeButton/GUIUpgradeButton.visible = false
	elif _select_medal >= 0:
		var level := g_Commander.get_war_medal_level(_select_medal)
		if level <= 0:
			level = 1
		$Medal/Label.text = "war medal {0} level {1}".format([_select_medal + 1, level])
		$MedalIntro/Label.text = "war medal {0} level {1} intro".format([_select_medal + 1, level])
		if level <= 2:
			$UpgradeButton/GUIUpgradeButton.visible = true
			$UpgradeButton/GUIUpgradeButton.need_medal = g_Commander.get_need_upgrade_medal(_select_medal)
		else:
			$UpgradeButton/GUIUpgradeButton.visible = false
	$CommanderMedal/GUICommanderMedal.rank = g_Commander.rank
	$WarMedal/GUIWarMedal.level = g_Commander.get_war_medal_level(WARMEDAL_ID.INFANTRY_MEDAL)
	$WarMedal2/GUIWarMedal.level = g_Commander.get_war_medal_level(WARMEDAL_ID.AIR_FORCE_MEDAL)
	$WarMedal3/GUIWarMedal.level = g_Commander.get_war_medal_level(WARMEDAL_ID.ARTILLERY_MEDAL)
	$WarMedal4/GUIWarMedal.level = g_Commander.get_war_medal_level(WARMEDAL_ID.ARMOUR_MEDAL)
	$WarMedal5/GUIWarMedal.level = g_Commander.get_war_medal_level(WARMEDAL_ID.NAVY_MEDAL)
	$WarMedal6/GUIWarMedal.level = g_Commander.get_war_medal_level(WARMEDAL_ID.COMMERCE_MEDAL)
	$GUIAdornMedal.refresh()


func _selected_medal(value: int) -> void:
	_select_medal = value
	for i in _list.size():
		_list[i].selected = i == value
		if i == value:
			_list[i].arrow_color = Color.GREEN
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
			$ecEffect.fire_at(pos.x, pos.y, 0.0)
			_set_commander_info()
	elif g_Commander.check_upgrade_war_medal(_select_medal):
		CSoundBox.get_instance().play_se("commander_lvup.wav")
		g_Commander.upgrade_war_medal(_select_medal)
		g_Commander.save()
		var medal: Control = _list[_select_medal]
		var pos = medal.global_position - global_position + medal.size / 2
		$ecEffect.fire_at(pos.x, pos.y, 0.0)
		_set_commander_info()
