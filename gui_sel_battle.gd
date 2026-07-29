extends GUIElement

const _CAMPAIGN_LOGO = [
	"logo_axis.png",
	"logo_allies.png",
	"logo_wto.png",
	"logo_nato.png"
]

@export
var texture_res: ecTextureRes:
	set(value):
		if value != texture_res:
			texture_res = value
			init()

@export
var game_mode: int:
	set(value):
		game_mode = value
		$ButtonInfo.visible = (value == 0)


@export
var campaign: int:
	get():
		return $GUIBattleList.campaign
	set(value):
		if value != campaign:
			$GUIBattleList.campaign = value
			init()


var _battle := -1

signal ok_pressed

func init() -> void:
	if not is_node_ready():
		return
	super()
	var loc := g_LocalizableStrings.get_string(&"language")
	if ecGraphics.instance().content_scale_size_mode == 3:
		s_texture_res.load_res("selbattle_hd.xml", false)
		s_texture_res.load_res("battlename_{0}_hd.xml".format([loc]), false)
	elif EC2dAppDelegate.g_content_scale_factor == 2.0:
		s_texture_res.load_res("selbattle_hd.xml", true)
		s_texture_res.load_res("battlename_{0}_hd.xml".format([loc]), true)
	else:
		s_texture_res.load_res("selbattle.xml", false)
		s_texture_res.load_res("battlename_{0}.xml".format([loc]), false)
	var logo: Texture2D = null
	var res := texture_res
	if res == null:
		res = s_texture_res
	if res != null and campaign < _CAMPAIGN_LOGO.size():
		logo = res.get_image(_CAMPAIGN_LOGO[campaign])
	$Logo/TextureRect.texture = logo
	_battle = -1
	if game_mode != 4 and g_Commander.get_num_played_battles(campaign) < AppDelegate.get_num_battles(campaign):
		$GUIBattleList.select_last_unlocked()
	else:
		$GUIBattleList.set_select(0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		var loc := g_LocalizableStrings.get_string(&"language")
		if ecGraphics.instance().content_scale_size_mode == 3:
			s_texture_res.unload_res("selbattle_hd.xml")
			s_texture_res.unload_res("battlename_{0}_hd.xml".format([loc]))
		elif EC2dAppDelegate.g_content_scale_factor == 2.0:
			s_texture_res.unload_res("selbattle_hd.xml")
			s_texture_res.unload_res("battlename_{0}_hd.xml".format([loc]))
		else:
			s_texture_res.unload_res("selbattle.xml")
			s_texture_res.unload_res("battlename_{0}.xml".format([loc]))


func _on_gui_battle_list_battle_selected(battle: int) -> void:
	_sel_battle(campaign, battle)
	_battle = battle


func _sel_battle(sel_campaign: int, battle: int) -> void:
	_load_image_list(sel_campaign, battle)


func _load_image_list(sel_campaign: int, battle: int) -> void:
	var key = AppDelegate.get_battle_key_name(sel_campaign, battle)
	var def := CObjectDef.instance().get_battle_def(key)
	if def == null:
		return
	if _battle < 0:
		$GUISelBattleCommon.set_image_list(def.flag, def.arrow, def.age, Vector2(def.agex, def.agey), Vector2(def.centerx, def.centery))
	else:
		$GUISelBattleCommon.change_image_list(def.flag, def.arrow, def.age, Vector2(def.agex, def.agey), Vector2(def.centerx, def.centery))


func _on_button_info_pressed() -> void:
	$GUIBattleIntro.campaign = campaign
	$GUIBattleIntro.battle = _battle
	$GUIBattleIntro.show()


func _on_gui_battle_intro_ok_pressed() -> void:
	$GUIBattleIntro.hide()


func _on_button_ok_pressed() -> void:
	g_GameManager.new_game(1, -1, campaign, _battle)
	ok_pressed.emit()


func _on_button_back_pressed() -> void:
	back_pressed.emit()
