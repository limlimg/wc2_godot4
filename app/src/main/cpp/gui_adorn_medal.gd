extends "res://app/src/main/cpp/gui_element.gd"

const _ecTextureResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_texture_res_assets.gd")
const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")
const _WarMedalId = preload("res://app/src/main/cpp/war_medal_id.gd").WARMEDAL_ID

func _ready() -> void:
	init()


func init() -> void:
	refresh()


func refresh() -> void:
	$CommanderLevel/Control/GUICommanderMedal.rank = g_Commander.rank
	var level := g_Commander.get_war_medal_level(_WarMedalId.INFANTRY_MEDAL)
	$Medal/Control/GUIWarMedal.level = level
	$Medal/Control/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(_WarMedalId.AIR_FORCE_MEDAL)
	$Medal2/Control/GUIWarMedal.level = level
	$Medal2/Control/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(_WarMedalId.ARTILLERY_MEDAL)
	$Medal3/Control/GUIWarMedal.level = level
	$Medal3/Control/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(_WarMedalId.ARMOUR_MEDAL)
	$Medal4/Control/GUIWarMedal.level = level
	$Medal4/Control/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(_WarMedalId.NAVY_MEDAL)
	$Medal5/Control/GUIWarMedal.level = level
	$Medal5/Control/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(_WarMedalId.COMMERCE_MEDAL)
	$Medal6/Control/GUIWarMedal.level = level
	$Medal6/Control/GUIWarMedal.visible = level > 0
