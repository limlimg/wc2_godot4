extends "res://app/src/main/cpp/gui_element.gd"

const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")

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

func _ready() -> void:
	#_GUIManager.s_texture_res = load("res://app/src/main/cpp/scene_system_resource/menu_gui_res/texture_res.tres").get_res()
	var commander := g_Commander
	if commander.get_num_played_battles(0) < _native.get_num_battles(0)\
			and commander.get_num_played_battles(1) < _native.get_num_battles(1):
		$SelCampaigns/ButtonWto/GUIButton.grey_scale = 0.7
		$SelCampaigns/ButtonNato/GUIButton.grey_scale = 0.7
	else:
		$SelCampaigns/ButtonWto/GUIButton/Locked/TextureRect.visible = false
		$SelCampaigns/ButtonNato/GUIButton/Locked/TextureRect.visible = false
	# NOTTODO: refresh the "new" highlight of the more games button
	_native.main_menu_loaded_jni()


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
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		if _state == 0:
			for button in [$SelCampaigns/ButtonBack/GUIButton, $SelConquest/GUIRect10/ButtonBack]:
				if button.is_visible_in_tree():
					button.pressed.emit()
					break
		get_viewport().set_input_as_handled()


func _on_button_campaign_pressed() -> void:
	if _state == 0:
		# NOTTODO: hide more game and mail button
		_move_button(2)
		_CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_sel_campaign_pressed(sel_campaign: int) -> void:
	if _state == 0:
		sel_campaign_pressed.emit(sel_campaign)


func _on_button_load_campaign_pressed() -> void:
	if _state == 0:
		load_campaign_pressed.emit()


func _on_button_campaign_back_pressed() -> void:
	if _state == 0:
		_move_button(4)
		_CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_conquest_pressed() -> void:
	if _state == 0:
		# NOTTODO: hide more game and mail button
		_move_button(7)
		_CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_sel_conquest_pressed(sel_conquest: int) -> void:
	if _state == 0:
		sel_conquest_pressed.emit(sel_conquest)


func _on_button_load_conquest_pressed() -> void:
	if _state == 0:
		load_conquest_pressed.emit()


func _on_button_conquest_back_pressed() -> void:
	if _state == 0:
		_move_button(9)
		_CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_multi_player_pressed() -> void:
	if _state == 0:
		# NOTTODO: hide more game and mail button
		_move_button(6)
		_CSoundBox.get_instance().play_se("main_interface.wav")


func _on_button_multi_player_global_pressed() -> void:
	if _state == 0:
		multi_player_global_pressed.emit()


func _on_button_local_pressed() -> void:
	if _state == 0:
		$SelMultiplayer.hide()
		$SelLocal.show()


func _on_button_multi_player_host_pressed() -> void:
	if _state == 0:
		multi_player_host_pressed.emit()


func _on_button_multi_player_join_pressed() -> void:
	if _state == 0:
		multi_player_join_pressed.emit()


func _on_button_local_back_pressed() -> void:
	if _state == 0:
		$SelMultiplayer.show()
		$SelLocal.hide()


func _on_button_multi_player_back_pressed() -> void:
	if _state == 0:
		# NOTTODO: show more game button and mail button and refresh new highlight
		_move_button(5)
		_CSoundBox.get_instance().play_se("main_interface.wav")


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
			$AnimationPlayer.speed_scale = 1.0
			$AnimationPlayer.play(&"move_main")
		2:
			$AnimationPlayer.play_backwards(&"move_main")
		3:
			$AnimationPlayer.speed_scale = $MainButton.size.x / size.x * 2.0
			$AnimationPlayer.play(&"move_campaign")
		4:
			$AnimationPlayer.play_backwards(&"move_campaign")
		5:
			_move_button(1)
		6:
			$AnimationPlayer.play_backwards(&"move_main")
		7:
			$AnimationPlayer.play_backwards(&"move_main")
		8:
			$AnimationPlayer.speed_scale = $MainButton.size.x / size.x * 2.0
			$AnimationPlayer.play(&"move_conquest")
		9:
			$AnimationPlayer.play_backwards(&"move_conquest")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	match _state:
		1:
			_move_button(0)
		2:
			_move_button(3)
		3:
			_move_button(0)
		4:
			_move_button(5)
		6:
			$SelMultiplayer.show()
			_move_button(0)
		7:
			_move_button(8)
		8:
			_move_button(0)
		9:
			_move_button(5)
