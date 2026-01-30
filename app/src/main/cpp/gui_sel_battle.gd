extends Control

const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")
const _ecImage = preload("res://app/src/main/cpp/ec_image.gd")

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
	set(value):
		if value != campaign:
			campaign = value
			var logo: Texture2D = null
			if value in _CAMPAIGN_LOGO:
				logo = load(_CAMPAIGN_LOGO[value]) as Texture2D
			$Logo/TextureRect.texture = logo


func init(init_game_mode: int, init_campaign: int) -> void:
	game_mode = init_game_mode
	campaign = init_campaign
	_GUIManager.instance().s_texture_res = load("res://app/src/main/cpp/scene_system_resource/selbattle_res/texture_res.tres").get_res()
