extends "res://app/src/main/cpp/gui_element.gd"

const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _WarMedalId = preload("res://app/src/main/cpp/war_medal_id.gd").WARMEDAL_ID
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")

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

signal back_pressed

func _ready() -> void:
	init()


func init() -> void:
	$CommanderMedal/GUICommanderMedal.rank = g_Commander.rank
	_select_medal = -1
	_set_commander_info()


func _set_commander_info() -> void:
	if _select_medal == 6:
		var table := _native.g_string_table
		var rank := g_Commander.rank + 1
		$Medal/ecText.text = table.get_string("rank {0}".format([rank]))
		$MedalIntro/ecText.text = table.get_string("rank {0} intro".format([rank]))
		if not g_Commander.is_max_level():
			$UpgradeButton/GUIUpgradeButton.visible = true
			$UpgradeButton/GUIUpgradeButton.need_medal = g_Commander.get_upgrade_medal()
		else:
			$UpgradeButton/GUIUpgradeButton.visible = false
	elif _select_medal >= 0:
		var table := _native.g_string_table
		var level := g_Commander.get_war_medal_level(_select_medal)
		if level <= 0:
			level = 1
		$Medal/ecText.text = table.get_string("war medal {0} level {1}".format([_select_medal + 1, level]))
		$MedalIntro/ecText.text = table.get_string("war medal {0} level {1} intro".format([_select_medal + 1, level]))
		if level <= 2:
			$UpgradeButton/GUIUpgradeButton.visible = true
			$UpgradeButton/GUIUpgradeButton.need_medal = g_Commander.get_need_upgrade_medal(_select_medal)
		else:
			$UpgradeButton/GUIUpgradeButton.visible = false
	$CommanderMedal/GUICommanderMedal.rank = g_Commander.rank
	$WarMedal/GUIWarMedal.level = g_Commander.get_war_medal_level(_WarMedalId.INFANTRY_MEDAL)
	$WarMedal2/GUIWarMedal.level = g_Commander.get_war_medal_level(_WarMedalId.AIR_FORCE_MEDAL)
	$WarMedal3/GUIWarMedal.level = g_Commander.get_war_medal_level(_WarMedalId.ARTILLERY_MEDAL)
	$WarMedal4/GUIWarMedal.level = g_Commander.get_war_medal_level(_WarMedalId.ARMOUR_MEDAL)
	$WarMedal5/GUIWarMedal.level = g_Commander.get_war_medal_level(_WarMedalId.NAVY_MEDAL)
	$WarMedal6/GUIWarMedal.level = g_Commander.get_war_medal_level(_WarMedalId.COMMERCE_MEDAL)
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
			_CSoundBox.get_instance().play_se("commander_lvup.wav")
			g_Commander.upgrade()
			g_Commander.save()
			var pos: Vector2
			if _ecGraphics.instance().content_scale_size_mode == 3:
				pos = Vector2(554, 560)
			else:
				pos = Vector2(246, 244)
			$ecEffect.fire_at(pos.x, pos.y, 0.0)
			_set_commander_info()
	elif g_Commander.check_upgrade_war_medal(_select_medal):
		_CSoundBox.get_instance().play_se("commander_lvup.wav")
		g_Commander.upgrade_war_medal(_select_medal)
		g_Commander.save()
		var medal: Control = _list[_select_medal]
		var pos = medal.global_position - global_position + medal.size / 2
		$ecEffect.fire_at(pos.x, pos.y, 0.0)
		_set_commander_info()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		back_pressed.emit()
