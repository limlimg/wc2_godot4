extends Control

const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")
const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")

var _button_moving := 0

signal button_campaign_pressed
signal button_campaign_back_pressed
signal button_conquest_pressed
signal button_conquest_back_pressed
signal button_multi_player_pressed
signal button_multi_player_back_pressed
signal button_local_pressed
signal button_local_back_pressed
signal quit_pressed

func _ready() -> void:
	_GUIManager._s_texture_res = load("res://app/src/main/cpp/scene_system_resource/menu_gui_res/texture_res.tres").get_res()
	var commander := g_Commander
	if commander.get_num_played_battles(0) < _native.get_num_battles(0)\
			and commander.get_num_played_battles(1) < _native.get_num_battles(1):
		$GUIiPad/SelCampaigns/ButtonWto.grey_scale = 0.7
		$GUIiPad/SelCampaigns/ButtonNato.grey_scale = 0.7
	else:
		$GUIiPad/SelCampaigns/ButtonWto/Locked.visible = false
		$GUIiPad/SelCampaigns/ButtonNato/Locked.visible = false
	# NOTTODO: refresh the "new" highlight of the more games button
	_native.main_menu_loaded_jni()


func move_in_main_buttons() -> void:
	_move_button(1)


func refresh_new_tip() -> void:
	# Not implemented
	is_show_new_tip()


func is_show_new_tip() -> bool:
	# Not implemented
	return false


func show_ad() -> void:
	# Not implemented
	pass


# OnEvent
# NOTTODO: more game button and mail button pressed
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		if _button_moving == 0:
			for button in [$GUIiPad/SelCampaigns/ButtonBack, $GUIiPad/SelConquest/ButtonBack]:
				if button.is_visible_in_tree():
					button.pressed.emit()
					break
		get_viewport().set_input_as_handled()


func _on_button_campaign_pressed() -> void:
	if _button_moving == 0:
		# NOTTODO: hide more game and mail button
		_move_button(2)
		_CSoundBox.get_instance().play_se("main_interface.wav")
	button_campaign_pressed.emit()


func _on_button_campaign_back_pressed() -> void:
	if _button_moving == 0:
		_move_button(4)
		_CSoundBox.get_instance().play_se("main_interface.wav")
	button_campaign_back_pressed.emit()


func _on_button_conquest_pressed() -> void:
	if _button_moving == 0:
		# NOTTODO: hide more game and mail button
		_move_button(7)
		_CSoundBox.get_instance().play_se("main_interface.wav")
	button_conquest_pressed.emit()


func _on_button_conquest_back_pressed() -> void:
	if _button_moving == 0:
		_move_button(9)
		_CSoundBox.get_instance().play_se("main_interface.wav")
	button_conquest_back_pressed.emit()


func _on_button_multi_player_pressed() -> void:
	if _button_moving == 0:
		# NOTTODO: hide more game and mail button
		_move_button(6)
		_CSoundBox.get_instance().play_se("main_interface.wav")
	button_multi_player_pressed.emit()


func _on_button_multi_player_back_pressed() -> void:
	if _button_moving == 0:
		# NOTTODO: show more game button and mail button and refresh new highlight
		_move_button(5)
		_CSoundBox.get_instance().play_se("main_interface.wav")
	button_multi_player_back_pressed.emit()


func _on_button_local_pressed() -> void:
	if _button_moving == 0:
		$GUIiPad/SelMultiplayer.hide()
		$GUIiPad/SelLocal.show()
	button_local_pressed.emit()


func _on_button_local_back_pressed() -> void:
	if _button_moving == 0:
		$GUIiPad/SelMultiplayer.show()
		$GUIiPad/SelLocal.hide()
	button_local_back_pressed.emit()


func _on_button_quit_pressed() -> void:
	if _button_moving == 0:
		quit_pressed.emit()


# OnUpdate
func _move_button(type: int) -> void:
	_button_moving = type
	var tween: Tween
	var target: Vector2
	var button_moving_speed: float
	if _ecGraphics.instance().content_scale_size_mode == 3:
		button_moving_speed = 800.0
	else:
		button_moving_speed = 400.0
	var t: float
	if type == 1:
		var main_button: Control = $GUIiPad/MainButtonContainer
		target = Vector2(size.x - main_button.size.x, main_button.position.y)
		t = main_button.size.x / button_moving_speed
		tween = create_tween()
		tween.tween_property(main_button, ^"position", target, t)
		tween.tween_callback(_move_button.bind(0))
	if type == 2 or type == 6 or type == 7:
		var main_button: Control = $GUIiPad/MainButtonContainer
		target = Vector2(size.x, main_button.position.y)
		t = (size.x - main_button.position.x) / button_moving_speed
		tween = create_tween()
		tween.tween_property(main_button, ^"position", target, t)
		if type == 2:
			tween.tween_callback(_move_button.bind(3))
		elif type == 6:
			tween.tween_callback($GUIiPad/SelMultiplayer.show)
			tween.tween_callback(_move_button.bind(0))
		else:
			tween.tween_callback(_move_button.bind(8))
	elif type == 3:
		$GUIiPad/SelCampaigns.show()
		tween = create_tween()
		for button in [$GUIiPad/SelCampaigns/ButtonAxis, $GUIiPad/SelCampaigns/ButtonWto]:
			t = (button.position.x + button.size.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", button.position, t)
			button.position = Vector2(-button.size.x, button.position.y)
		for button in [$GUIiPad/SelCampaigns/ButtonAllies, $GUIiPad/SelCampaigns/ButtonNato]:
			t = (size.x - button.position.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", button.position, t)
			button.position = Vector2(size.x, button.position.y)
		tween.tween_callback(_move_button.bind(0))
	elif type == 4:
		tween = create_tween()
		for button in [$GUIiPad/SelCampaigns/ButtonAxis, $GUIiPad/SelCampaigns/ButtonWto]:
			target = Vector2(-button.size.x, button.position.y)
			t = (button.position.x + button.size.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", target, t)
		for button in [$GUIiPad/SelCampaigns/ButtonAllies, $GUIiPad/SelCampaigns/ButtonNato]:
			target = Vector2(size.x, button.position.y)
			t = (size.x - button.position.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", target, t)
		tween.tween_callback(_move_button.bind(5))
		# NOTTODO: show more game button and mail button and refresh new highlight
		for button in [$GUIiPad/SelCampaigns/ButtonAxis, $GUIiPad/SelCampaigns/ButtonWto]:
			tween.tween_property(button, ^"position", button.position, 0)
		for button in [$GUIiPad/SelCampaigns/ButtonAllies, $GUIiPad/SelCampaigns/ButtonNato]:
			tween.tween_property(button, ^"position", button.position, 0)
		tween.tween_callback(_move_button.bind(0))
	elif type == 5:
		$GUIiPad/SelCampaigns.hide()
		$GUIiPad/SelConquest.hide()
		_move_button(1)
	elif type == 8:
		$GUIiPad/SelConquest.show()
		tween = create_tween()
		tween.tween_interval(0)
		for button in [$GUIiPad/SelConquest/Button1, $GUIiPad/SelConquest/Button3, $GUIiPad/SelConquest/Button5, $GUIiPad/SelConquest/Button7]:
			t = (button.position.x + button.size.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", button.position, t)
			button.position = Vector2(-button.size.x, button.position.y)
		for button in [$GUIiPad/SelConquest/Button2, $GUIiPad/SelConquest/Button4, $GUIiPad/SelConquest/Button6, $GUIiPad/SelConquest/Button8]:
			t = (size.x - button.position.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", button.position, t)
			button.position = Vector2(size.x, button.position.y)
		tween.tween_callback(_move_button.bind(0))
	elif type == 9:
		tween = create_tween()
		tween.tween_interval(0)
		for button in [$GUIiPad/SelConquest/Button1, $GUIiPad/SelConquest/Button3, $GUIiPad/SelConquest/Button5, $GUIiPad/SelConquest/Button7]:
			target = Vector2(-button.size.x, button.position.y)
			t = (button.position.x + button.size.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", target, t)
		for button in [$GUIiPad/SelConquest/Button2, $GUIiPad/SelConquest/Button4, $GUIiPad/SelConquest/Button6, $GUIiPad/SelConquest/Button8]:
			target = Vector2(size.x, button.position.y)
			t = (size.x - button.position.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", target, t)
		tween.tween_callback(_move_button.bind(5))
		# NOTTODO: show more game button and mail button and refresh new highlight
		for button in [$GUIiPad/SelConquest/Button1, $GUIiPad/SelConquest/Button3, $GUIiPad/SelConquest/Button5, $GUIiPad/SelConquest/Button7]:
			tween.tween_property(button, ^"position", button.position, 0)
		for button in [$GUIiPad/SelConquest/Button2, $GUIiPad/SelConquest/Button4, $GUIiPad/SelConquest/Button6, $GUIiPad/SelConquest/Button8]:
			tween.tween_property(button, ^"position", button.position, 0)
		tween.tween_callback(_move_button.bind(0))
