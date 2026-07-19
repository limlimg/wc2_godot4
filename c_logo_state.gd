extends CBaseState

var _logo: Control

func _on_enter() -> void:
	_logo = $Logo/GUIImage.create_instance()
	g_GameSettings.load_settings()
	var sound_box := CSoundBox.get_instance()
	sound_box.set_music_volume(g_GameSettings.music_volume)
	sound_box.set_se_volume(g_GameSettings.se_volume)
	#GUIManager.s_texture_res = load("res://scene_system_resource/logo_gui_res/texture_res.tres").get_res()
	var tween := create_tween()
	tween.tween_interval(2.1)
	tween.tween_callback(func ():
		GUIManager.instance().fade_out(-1, null))
	GUIManager.instance().faded_out.connect(func (_cause: int):
		var tween2 := create_tween()
		tween2.tween_interval(1.0)
		# TODO: initialize player manager
		CStateManager.instance().set_cur_state(EState.MENU)
		)


func _on_exit() -> void:
	_logo.queue_free()
