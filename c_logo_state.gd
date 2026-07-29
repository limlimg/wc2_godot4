extends CBaseState

func _on_enter() -> void:
	$GUIImage.create_instance().reparent(GUIManager.instance())
	g_GameSettings.load_settings()
	var sound_box := CSoundBox.get_instance()
	sound_box.set_music_volume(g_GameSettings.music_volume)
	sound_box.set_se_volume(g_GameSettings.se_volume)
	var graphics := ecGraphics.instance()
	var gui_manager := GUIManager.instance()
	if graphics.content_scale_size_mode == 3:
		gui_manager.load_texture_res("ui_iPad.xml", false)
	if EC2dAppDelegate.g_content_scale_factor == 2.0:
		gui_manager.load_texture_res("ui1_hd.xml", true)
	else:
		gui_manager.load_texture_res("ui1.xml", false)
	if graphics.content_scale_size_mode == 3:
		gui_manager.load_texture_res("ui2_hd.xml", false)
	elif EC2dAppDelegate.g_content_scale_factor == 2.0:
		gui_manager.load_texture_res("ui2_hd.xml", true)
	else:
		gui_manager.load_texture_res("ui2.xml", false)
	var loc := g_LocalizableStrings.get_string(&"language")
	if graphics.content_scale_size_mode == 3:
		if EC2dAppDelegate.g_content_scale_factor == 2.0:
			gui_manager.load_texture_res("text_{0}_iPad_hd.xml".format([loc]), true)
		else:
			gui_manager.load_texture_res("text_{0}_iPad.xml".format([loc]), false)
	elif EC2dAppDelegate.g_content_scale_factor == 2.0:
		gui_manager.load_texture_res("text_{0}_hd.xml".format([loc]), true)
	else:
		gui_manager.load_texture_res("text_{0}.xml".format([loc]), false)
	#if graphics.content_scale_size_mode == 3:
		#gui_manager.load_texture_res("image_newgame_hd.xml", false)
	#elif EC2dAppDelegate.g_content_scale_factor == 2.0:
		#gui_manager.load_texture_res("image_newgame_hd.xml", true)
	#else:
		#gui_manager.load_texture_res("image_newgame.xml", false)
	var tween := create_tween()
	tween.tween_interval(2.1)
	tween.tween_callback(GUIManager.instance().fade_out.bind(-1, null))
	await GUIManager.instance().faded_out
	tween = create_tween()
	tween.tween_interval(1.0)
	# TODO: initialize player manager
	tween.tween_callback(CStateManager.instance().set_cur_state.bind(EState.MENU))


func _on_exit() -> void:
	GUIManager.instance().free_all_child()
