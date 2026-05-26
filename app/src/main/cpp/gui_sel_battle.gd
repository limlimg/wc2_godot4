extends "res://app/src/main/cpp/gui_element.gd"

const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")
const _ecImage = preload("res://app/src/main/cpp/ec_image.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _GUIBattleList = preload("res://app/src/main/cpp/gui_battle_list.gd")


const _CAMPAIGN_LOGO = [
	"res://app/src/main/cpp/scene_system_resource/selbattle_res/logo_axis.png.tres",
	"res://app/src/main/cpp/scene_system_resource/selbattle_res/logo_allies.png.tres",
	"res://app/src/main/cpp/scene_system_resource/selbattle_res/logo_wto.png.tres",
	"res://app/src/main/cpp/scene_system_resource/selbattle_res/logo_nato.png.tres"
]

@export
var game_mode: int:
	set(value):
		game_mode = value
		$ButtonInfo.visible = (value != 0)


@export
var campaign: int:
	get():
		return $GUIBattleList/GUIBattleList.campaign
	set(value):
		if value != campaign:
			$GUIBattleList/GUIBattleList.campaign = value
			if is_node_ready():
				init()


func _ready() -> void:
	init()


func init() -> void:
	var logo: Texture2D = null
	if campaign < _CAMPAIGN_LOGO.size():
		logo = load(_CAMPAIGN_LOGO[campaign]) as Texture2D
	$Logo/TextureRect.texture = logo
	_GUIElement.s_texture_res = load("res://app/src/main/cpp/scene_system_resource/selbattle_res/texture_res.tres").get_res()
	var _list := $GUIBattleList/GUIBattleList as _GUIBattleList
	if game_mode != 4 and g_Commander.get_num_played_battles(campaign) < _native.get_num_battles(campaign):
		_list.select_last_unlocked()
	else:
		_list.set_select(0)
