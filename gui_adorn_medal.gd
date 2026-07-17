extends GUIElement

func _ready() -> void:
	init()


func init() -> void:
	refresh()


func refresh() -> void:
	$CommanderLevel/GUICommanderMedal.rank = g_Commander.rank
	var level := g_Commander.get_war_medal_level(WARMEDAL_ID.INFANTRY_MEDAL)
	$Medal/GUIWarMedal.level = level
	$Medal/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(WARMEDAL_ID.AIR_FORCE_MEDAL)
	$Medal2/GUIWarMedal.level = level
	$Medal2/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(WARMEDAL_ID.ARTILLERY_MEDAL)
	$Medal3/GUIWarMedal.level = level
	$Medal3/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(WARMEDAL_ID.ARMOUR_MEDAL)
	$Medal4/GUIWarMedal.level = level
	$Medal4/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(WARMEDAL_ID.NAVY_MEDAL)
	$Medal5/GUIWarMedal.level = level
	$Medal5/GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(WARMEDAL_ID.COMMERCE_MEDAL)
	$Medal6/GUIWarMedal.level = level
	$Medal6/GUIWarMedal.visible = level > 0
