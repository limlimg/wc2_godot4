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
	var loc = g_LocalizableStrings.get_string(&"language")
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
		$FixedWidth/SelCampaigns/Left/ButtonWto.grey_scale = 0.7
		$FixedWidth/SelCampaigns/Right/ButtonNato.grey_scale = 0.7
	else:
		$FixedWidth/SelCampaigns/Left/ButtonWto/Locked.visible = false
		$FixedWidth/SelCampaigns/Right/ButtonNato/Locked.visible = false
	# NOTTODO: refresh the "new" highlight of the more games button


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		var loc = g_LocalizableStrings.get_string(&"language")
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
	_state = 1


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
		_state = 2
		CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_sel_campaign_pressed(sel_campaign: int) -> void:
	if _state == 0:
		sel_campaign_pressed.emit(sel_campaign)


func _on_button_load_campaign_pressed() -> void:
	if _state == 0:
		load_campaign_pressed.emit()


func _on_button_campaign_back_pressed() -> void:
	if _state == 0:
		_state = 4
		CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_conquest_pressed() -> void:
	if _state == 0:
		# NOTTODO: hide more game and mail button
		_state = 7
		CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_sel_conquest_pressed(sel_conquest: int) -> void:
	if _state == 0:
		sel_conquest_pressed.emit(sel_conquest)


func _on_button_load_conquest_pressed() -> void:
	if _state == 0:
		load_conquest_pressed.emit()


func _on_button_conquest_back_pressed() -> void:
	if _state == 0:
		_state = 9
		CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_multi_player_pressed() -> void:
	if _state == 0:
		# NOTTODO: hide more game and mail button
		_state = 6
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
		_state = 5
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


func _process(delta: float) -> void:
	var v := 800.0 if ecGraphics.instance().content_scale_size_mode == 3 else 400.0
	match _state:
		1:
			var dest = -$FixedWidth/MainButton.size.x
			var x := maxf($FixedWidth/MainButton/VBoxContainer.position.x - v * delta, dest)
			$FixedWidth/MainButton/VBoxContainer.position.x = x
			if x <= dest:
				_state = 0
		2:
			var dest = 0.0
			var x := minf($FixedWidth/MainButton/VBoxContainer.position.x + v * delta, dest)
			$FixedWidth/MainButton/VBoxContainer.position.x = x
			if x >= dest:
				_state = 3
				$FixedWidth/SelCampaigns.show()
		3:
			var dest = $FixedWidth.size.x / 2
			var x := minf($FixedWidth/SelCampaigns/Left.position.x + 2 * v * delta, dest)
			$FixedWidth/SelCampaigns/Left.position.x = x
			$FixedWidth/SelCampaigns/Right.position.x = $FixedWidth.size.x - x
			if x >= dest:
				_state = 0
		4:
			var dest = 0.0
			var x := maxf($FixedWidth/SelCampaigns/Left.position.x - 2 * v * delta, dest)
			$FixedWidth/SelCampaigns/Left.position.x = x
			$FixedWidth/SelCampaigns/Right.position.x = $FixedWidth.size.x - x
			if x <= dest:
				_state = 5
				$FixedWidth/SelCampaigns.hide()
				# NOTTODO: show mail and more game buttons
		5:
			var dest = -$FixedWidth/MainButton.size.x
			var x := maxf($FixedWidth/MainButton/VBoxContainer.position.x - v * delta, dest)
			$FixedWidth/MainButton/VBoxContainer.position.x = x
			if x <= dest:
				_state = 0
		6:
			var dest = 0.0
			var x := minf($FixedWidth/MainButton/VBoxContainer.position.x + v * delta, dest)
			$FixedWidth/MainButton/VBoxContainer.position.x = x
			if x >= dest:
				$SelMultiplayer.show()
				_state = 0
		7:
			var dest = 0.0
			var x := minf($FixedWidth/MainButton/VBoxContainer.position.x + v * delta, dest)
			$FixedWidth/MainButton/VBoxContainer.position.x = x
			if x >= dest:
				_state = 8
				$FixedWidth/SelConquest.show()
		8:
			var dest = $FixedWidth.size.x / 2
			var x := minf($FixedWidth/SelConquest/Left.position.x + 2 * v * delta, dest)
			$FixedWidth/SelConquest/Left.position.x = x
			$FixedWidth/SelConquest/Right.position.x = $FixedWidth.size.x - x
			if x >= dest:
				_state = 0
		9:
			var dest = 0.0
			var x := maxf($FixedWidth/SelConquest/Left.position.x - 2 * v * delta, dest)
			$FixedWidth/SelConquest/Left.position.x = x
			$FixedWidth/SelConquest/Right.position.x = $FixedWidth.size.x - x
			if x <= dest:
				_state = 5
				$FixedWidth/SelConquest.hide()
				# NOTTODO: show mail and more game buttons


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
	elif event.is_action_released(&"ui_cancel"):
		if _state != 0:
			accept_event()
		else:
			for button in [$FixedWidth/SelCampaigns/ButtonBack, $FixedWidth/SelConquest/ButtonBack]:
				if button.is_visible_in_tree():
					button.pressed.emit()
					accept_event()
					return
