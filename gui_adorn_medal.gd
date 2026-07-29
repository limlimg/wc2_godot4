extends GUIElement


func init() -> void:
	if not is_node_ready():
		return
	super()
	refresh()


func refresh() -> void:
	$GUICommanderMedal.rank = g_Commander.rank
	var level := g_Commander.get_war_medal_level(WARMEDAL_ID.INFANTRY_MEDAL)
	$GUIWarMedal.level = level
	$GUIWarMedal.visible = level > 0
	level = g_Commander.get_war_medal_level(WARMEDAL_ID.AIR_FORCE_MEDAL)
	$GUIWarMedal2.level = level
	$GUIWarMedal2.visible = level > 0
	level = g_Commander.get_war_medal_level(WARMEDAL_ID.ARTILLERY_MEDAL)
	$GUIWarMedal3.level = level
	$GUIWarMedal3.visible = level > 0
	level = g_Commander.get_war_medal_level(WARMEDAL_ID.ARMOUR_MEDAL)
	$GUIWarMedal4.level = level
	$GUIWarMedal4.visible = level > 0
	level = g_Commander.get_war_medal_level(WARMEDAL_ID.NAVY_MEDAL)
	$GUIWarMedal5.level = level
	$GUIWarMedal5.visible = level > 0
	level = g_Commander.get_war_medal_level(WARMEDAL_ID.COMMERCE_MEDAL)
	$GUIWarMedal6.level = level
	$GUIWarMedal6.visible = level > 0
