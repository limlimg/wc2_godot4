extends "res://app/src/main/cpp/c_base_state.gd"

const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")

static func init_game() -> void:
	g_SoundRes.load_res()
	# NOTTODO: initialize CFightManager; seems unnecessary
	g_GameRes.load_res()
	#_GUIManager.s_texture_res = load("res://app/src/main/cpp/scene_system_resource/game_gui_res/texture_res.tres").get_res()
	g_GameManager.init_battle()
	# NOTTODO: initialize CTouchInertia; not static var
