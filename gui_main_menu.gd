extends GUIElement

var _state := 0

signal sel_campaign_pressed(sel_campaign: int)
signal load_campaign_pressed
signal sel_conquest_pressed(sel_conquest: int)
signal load_conquest_pressed
signal multi_player_global_pressed
signal multi_player_host_pressed
signal multi_player_join_pressed
signal tutorial_pressed
signal commander_pressed
signal options_pressed
signal quit_pressed

func init():
	if not is_node_ready():
		return
	super()
	var loc := g_LocalizableStrings.get_string(&"language")
	var graphics := ecGraphics.instance()
	var gui_manager := GUIManager.instance()
	if graphics.content_scale_size_mode == 3:
		gui_manager.load_texture_res("mui_hd.xml", false)
		gui_manager.load_texture_res("mui2_hd.xml", false)
		gui_manager.load_texture_res("mui_{0}_hd.xml".format([loc]), false)
	elif EC2dAppDelegate.g_content_scale_factor == 2.0:
		gui_manager.load_texture_res("mui_hd.xml", true)
		gui_manager.load_texture_res("mui2_hd.xml", true)
		gui_manager.load_texture_res("mui_{0}_hd.xml".format([loc]), true)
	else:
		gui_manager.load_texture_res("mui.xml", false)
		gui_manager.load_texture_res("mui2.xml", false)
		gui_manager.load_texture_res("mui_{0}.xml".format([loc]), false)
	var commander := g_Commander
	if commander.get_num_played_battles(0) < AppDelegate.get_num_battles(0)\
			and commander.get_num_played_battles(1) < AppDelegate.get_num_battles(1):
		$FixedWidth/SelCampaigns/ButtonWto.grey_scale = 0.7
		$FixedWidth/SelCampaigns/ButtonNato.grey_scale = 0.7
	else:
		$FixedWidth/SelCampaigns/ButtonWto/Locked/TextureRect.visible = false
		$FixedWidth/SelCampaigns/ButtonNato/Locked/TextureRect.visible = false
	# NOTTODO: refresh the "new" highlight of the more games button


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		var loc := g_LocalizableStrings.get_string(&"language")
		var graphics := ecGraphics.instance()
		var gui_manager := GUIManager.instance()
		if graphics.content_scale_size_mode == 3:
			gui_manager.unload_texture_res("mui_hd.xml")
			gui_manager.unload_texture_res("mui2_hd.xml")
			gui_manager.unload_texture_res("mui_{0}_hd.xml".format([loc]))
		elif EC2dAppDelegate.g_content_scale_factor == 2.0:
			gui_manager.unload_texture_res("mui_hd.xml")
			gui_manager.unload_texture_res("mui2_hd.xml")
			gui_manager.unload_texture_res("mui_{0}_hd.xml".format([loc]))
		else:
			gui_manager.unload_texture_res("mui.xml")
			gui_manager.unload_texture_res("mui2.xml")
			gui_manager.unload_texture_res("mui_{0}.xml".format([loc]))


func move_in_main_buttons() -> void:
	_move_button(1)


func refresh_new_tip() -> void:
	# Not implemented
	_is_show_new_tip()


func _is_show_new_tip() -> bool:
	# Not implemented
	return false


func show_ad() -> void:
	# Not implemented
	pass


# OnEvent
# NOTTODO: more game button and mail button pressed
func _on_button_campaign_pressed() -> void:
	if _state == 0:
		# NOTTODO: hide more game and mail button
		_move_button(2)
		CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_sel_campaign_pressed(sel_campaign: int) -> void:
	if _state == 0:
		sel_campaign_pressed.emit(sel_campaign)


func _on_button_load_campaign_pressed() -> void:
	if _state == 0:
		load_campaign_pressed.emit()


func _on_button_campaign_back_pressed() -> void:
	if _state == 0:
		_move_button(4)
		CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_conquest_pressed() -> void:
	if _state == 0:
		# NOTTODO: hide more game and mail button
		_move_button(7)
		CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_sel_conquest_pressed(sel_conquest: int) -> void:
	if _state == 0:
		sel_conquest_pressed.emit(sel_conquest)


func _on_button_load_conquest_pressed() -> void:
	if _state == 0:
		load_conquest_pressed.emit()


func _on_button_conquest_back_pressed() -> void:
	if _state == 0:
		_move_button(9)
		CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_multi_player_pressed() -> void:
	if _state == 0:
		# NOTTODO: hide more game and mail button
		_move_button(6)
		CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_multi_player_global_pressed() -> void:
	if _state == 0:
		multi_player_global_pressed.emit()


func _on_button_local_pressed() -> void:
	if _state == 0:
		$FixedWidth/SelMultiplayer.hide()
		$FixedWidth/SelLocal.show()


func _on_button_multi_player_host_pressed() -> void:
	if _state == 0:
		multi_player_host_pressed.emit()


func _on_button_multi_player_join_pressed() -> void:
	if _state == 0:
		multi_player_join_pressed.emit()


func _on_button_local_back_pressed() -> void:
	if _state == 0:
		$FixedWidth/SelMultiplayer.show()
		$FixedWidth/SelLocal.hide()


func _on_button_multi_player_back_pressed() -> void:
	if _state == 0:
		# NOTTODO: show more game button and mail button and refresh new highlight
		_move_button(5)
		CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_tutorial_pressed() -> void:
	if _state == 0:
		tutorial_pressed.emit()


func _on_button_commander_pressed() -> void:
	if _state == 0:
		commander_pressed.emit()


func _on_button_options_pressed() -> void:
	if _state == 0:
		options_pressed.emit()


func _on_button_quit_pressed() -> void:
	if _state == 0:
		quit_pressed.emit()


func _move_button(state: int) -> void:
	_state = state
	match state:
		1:
			$AnimationPlayer.play(&"move_main")
			await $AnimationPlayer.animation_finished
			_move_button(0)
		2:
			$AnimationPlayer.play_backwards(&"move_main")
			await $AnimationPlayer.animation_finished
			_move_button(3)
		3:
			$AnimationPlayer.play(&"move_campaign")
			await $AnimationPlayer.animation_finished
			_move_button(0)
		4:
			$AnimationPlayer.play_backwards(&"move_campaign")
			await $AnimationPlayer.animation_finished
			_move_button(5)
		5:
			_move_button(1)
		6:
			$AnimationPlayer.play_backwards(&"move_main")
			await $AnimationPlayer.animation_finished
			$SelMultiplayer.show()
			_move_button(0)
		7:
			$AnimationPlayer.play_backwards(&"move_main")
			await $AnimationPlayer.animation_finished
			_move_button(8)
		8:
			$AnimationPlayer.play(&"move_conquest")
			await $AnimationPlayer.animation_finished
			_move_button(0)
		9:
			$AnimationPlayer.play_backwards(&"move_conquest")
			await $AnimationPlayer.animation_finished
			_move_button(5)


func _on_back_pressed() -> void:
	if _state == 0:
		for button in [$FixedWidth/SelCampaigns/ButtonBack, $FixedWidth/SelConquest/ButtonBack]:
			if button.is_visible_in_tree():
				button.pressed.emit()
				accept_event()
				return
		quit_pressed.emit()
