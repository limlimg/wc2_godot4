extends "res://app/src/main/cpp/gui_element.gd"

const _WarMedalId = preload("res://app/src/main/cpp/war_medal_id.gd").WARMEDAL_ID

func _ready() -> void:
	init()


func init() -> void:
	refresh()


func refresh() -> void:
	$CommanderLevel/GUICommanderMedal.rank = g_Commander.rank
	var level := g_Commander.get_war_medal_level(_WarMedalId.INFANTRY_MEDAL)
	$Medal/GUIWarMedal.level = level
	$Medal/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(_WarMedalId.AIR_FORCE_MEDAL)
	$Medal2/GUIWarMedal.level = level
	$Medal2/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(_WarMedalId.ARTILLERY_MEDAL)
	$Medal3/GUIWarMedal.level = level
	$Medal3/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(_WarMedalId.ARMOUR_MEDAL)
	$Medal4/GUIWarMedal.level = level
	$Medal4/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(_WarMedalId.NAVY_MEDAL)
	$Medal5/GUIWarMedal.level = level
	$Medal5/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(_WarMedalId.COMMERCE_MEDAL)
	$Medal6/GUIWarMedal.level = level
	$Medal6/GUIWarMedal.visible = level > 0
