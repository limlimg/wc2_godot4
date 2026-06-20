extends "res://app/src/main/cpp/gui_element.gd"

const _ecTextureResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_texture_res_assets.gd")
const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")
const _ecImage = preload("res://app/src/main/cpp/ec_image.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _GUIBattleList = preload("res://app/src/main/cpp/gui_battle_list.gd")
const _CObjectDef = preload("res://app/src/main/cpp/c_object_def.gd")
const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")

const _CAMPAIGN_LOGO = [
	"logo_axis.png",
	"logo_allies.png",
	"logo_wto.png",
	"logo_nato.png"
]

@export
var texture_res: _ecTextureResAssets:
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
		return $GUIBattleList/GUIBattleList.campaign
	set(value):
		if value != campaign:
			$GUIBattleList/GUIBattleList.campaign = value
			init()


var _battle := -1

signal ok_pressed
signal back_pressed

func _ready() -> void:
	init()


func init() -> void:
	var logo: Texture2D = null
	if texture_res != null and campaign < _CAMPAIGN_LOGO.size():
		logo = _ecImageTexture.from_ec_image_attr(texture_res.get_res().get_image(_CAMPAIGN_LOGO[campaign]))
	$Logo/TextureRect.texture = logo
	#s_texture_res = load("res://app/src/main/cpp/scene_system_resource/selbattle_res/texture_res.tres").get_res()
	_battle = -1
	if game_mode != 4 and g_Commander.get_num_played_battles(campaign) < _native.get_num_battles(campaign):
		$GUIBattleList/GUIBattleList.select_last_unlocked()
	else:
		$GUIBattleList/GUIBattleList.set_select(0)


func _on_gui_battle_list_battle_selected(battle: int) -> void:
	_sel_battle(campaign, battle)
	_battle = battle


func _sel_battle(sel_campaign: int, battle: int) -> void:
	_load_image_list(sel_campaign, battle)


func _load_image_list(sel_campaign: int, battle: int) -> void:
	var key := _native.get_battle_key_name(sel_campaign, battle)
	var def := _CObjectDef.instance().get_battle_def(key)
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


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		back_pressed.emit()
