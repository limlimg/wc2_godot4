extends "res://app/src/main/cpp/c_base_state.gd"

const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")
const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")
const _CStateManager = preload("res://app/src/main/cpp/c_state_manager.gd")

func _on_enter() -> void:
	g_GameSettings.load_settings()
	var sound_box := _CSoundBox.get_instance()
	sound_box.set_music_volume(g_GameSettings.music_volume)
	sound_box.set_se_volume(g_GameSettings.se_volume)
	_GUIManager.s_texture_res = load("res://app/src/main/cpp/scene_system_resource/logo_gui_res/texture_res.tres").get_res()
	var tween := create_tween()
	tween.tween_interval(2.1)
	tween.tween_callback(func ():
		$GUIManager.fade_out(-1, null))
	$GUIManager.faded_out.connect(func (_cause: int):
		var tween2 := create_tween()
		tween2.tween_interval(1.0)
		# TODO: initialize player manager
		_CStateManager.instance().set_cur_state("res://app/src/main/cpp/c_menu_state.tscn")
		)
