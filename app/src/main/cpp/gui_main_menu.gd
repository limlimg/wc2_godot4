extends Control

const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")

@export
var button_moving_speed := 400

var _campaign_left_x: float
var _campaign_right_x: float
var _conquest_left_x: float
var _conquest_right_x: float
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
	var commander := _native.g_commander
	if commander.get_num_played_battles(0) < _native.get_num_battles(0)\
			and commander.get_num_played_battles(1) < _native.get_num_battles(1):
		$SelCampaigns/ButtonWto.grey_scale = 0.7
		$SelCampaigns/ButtonNato.grey_scale = 0.7
	else:
		$SelCampaigns/ButtonWto/Locked.visible = false
		$SelCampaigns/ButtonNato/Locked.visible = false
	_campaign_left_x = $SelCampaigns/ButtonAxis.position.x
	_campaign_right_x = $SelCampaigns/ButtonAllies.position.x
	_conquest_left_x = $SelConquest/Button1.position.x
	_conquest_right_x = $SelConquest/Button2.position.x
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
			for button in [$SelCampaigns/ButtonBack, $SelConquest/ButtonBack]:
				if button.is_visible_in_tree():
					button.pressed.emit()
					break
		get_viewport().set_input_as_handled()


func _on_button_campaign_pressed() -> void:
	# NOTTODO: hide more game and mail button
	_move_button(2)
	_CSoundBox.get_instance().play_se("main_interface.wav")
	button_campaign_pressed.emit()


func _on_button_campaign_back_pressed() -> void:
	_move_button(4)
	_CSoundBox.get_instance().play_se("main_interface.wav")
	button_campaign_back_pressed.emit()


func _on_button_conquest_pressed() -> void:
	# NOTTODO: hide more game and mail button
	_move_button(7)
	_CSoundBox.get_instance().play_se("main_interface.wav")
	button_conquest_pressed.emit()


func _on_button_conquest_back_pressed() -> void:
	_move_button(9)
	_CSoundBox.get_instance().play_se("main_interface.wav")
	button_conquest_back_pressed.emit()


func _on_button_multi_player_pressed() -> void:
	# NOTTODO: hide more game and mail button
	_move_button(6)
	_CSoundBox.get_instance().play_se("main_interface.wav")
	button_multi_player_pressed.emit()


func _on_button_multi_player_back_pressed() -> void:
	# NOTTODO: show more game button and mail button and refresh new highlight
	_move_button(5)
	_CSoundBox.get_instance().play_se("main_interface.wav")
	button_multi_player_back_pressed.emit()


func _on_button_local_pressed() -> void:
	$SelMultiplayer.hide()
	$SelLocal.show()
	button_local_pressed.emit()


func _on_button_local_back_pressed() -> void:
	$SelMultiplayer.show()
	$SelLocal.hide()
	button_local_back_pressed.emit()


func _on_button_quit_pressed() -> void:
	quit_pressed.emit()


# OnUpdate
func _move_button(type: int) -> void:
	_button_moving = type
	var tween: Tween
	var target: Vector2
	var t: float
	if type == 1:
		var main_button: Control = $MainButtonContainer
		target = Vector2(size.x - main_button.size.x, main_button.position.y)
		t = main_button.size.x / button_moving_speed
		tween = create_tween()
		tween.tween_property(main_button, ^"position", target, t)
		tween.tween_callback(_move_button.bind(0))
	if type == 2 or type == 6 or type == 7:
		var main_button: Control = $MainButtonContainer
		target = Vector2(size.x, main_button.position.y)
		t = (size.x - main_button.position.x) / button_moving_speed
		tween = create_tween()
		tween.tween_property(main_button, ^"position", target, t)
		if type == 2:
			tween.tween_callback(_move_button.bind(3))
		elif type == 6:
			tween.tween_callback($SelMultiplayer.show)
			tween.tween_callback(_move_button.bind(0))
		else:
			tween.tween_callback(_move_button.bind(8))
	elif type == 3:
		$SelCampaigns.show()
		tween = create_tween()
		for button in [$SelCampaigns/ButtonAxis, $SelCampaigns/ButtonWto]:
			t = (button.position.x + button.size.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", button.position, t)
			button.position = Vector2(-button.size.x, button.position.y)
		for button in [$SelCampaigns/ButtonAllies, $SelCampaigns/ButtonNato]:
			t = (size.x - button.position.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", button.position, t)
			button.position = Vector2(size.x, button.position.y)
		tween.tween_callback(_move_button.bind(0))
	elif type == 4:
		tween = create_tween()
		for button in [$SelCampaigns/ButtonAxis, $SelCampaigns/ButtonWto]:
			target = Vector2(-button.size.x, button.position.y)
			t = (button.position.x + button.size.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", target, t)
		for button in [$SelCampaigns/ButtonAllies, $SelCampaigns/ButtonNato]:
			target = Vector2(size.x, button.position.y)
			t = (size.x - button.position.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", target, t)
		tween.tween_callback(_move_button.bind(5))
		# NOTTODO: show more game button and mail button and refresh new highlight
		for button in [$SelCampaigns/ButtonAxis, $SelCampaigns/ButtonWto]:
			tween.tween_property(button, ^"position", button.position, 0)
		for button in [$SelCampaigns/ButtonAllies, $SelCampaigns/ButtonNato]:
			tween.tween_property(button, ^"position", button.position, 0)
		tween.tween_callback(_move_button.bind(0))
	elif type == 5:
		$SelCampaigns.hide()
		$SelConquest.hide()
		_move_button(1)
	elif type == 8:
		$SelConquest.show()
		tween = create_tween()
		tween.tween_interval(0)
		for button in [$SelConquest/Button1, $SelConquest/Button3, $SelConquest/Button5, $SelConquest/Button7]:
			t = (button.position.x + button.size.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", button.position, t)
			button.position = Vector2(-button.size.x, button.position.y)
		for button in [$SelConquest/Button2, $SelConquest/Button4, $SelConquest/Button6, $SelConquest/Button8]:
			t = (size.x - button.position.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", button.position, t)
			button.position = Vector2(size.x, button.position.y)
		tween.tween_callback(_move_button.bind(0))
	elif type == 9:
		tween = create_tween()
		tween.tween_interval(0)
		for button in [$SelConquest/Button1, $SelConquest/Button3, $SelConquest/Button5, $SelConquest/Button7]:
			target = Vector2(-button.size.x, button.position.y)
			t = (button.position.x + button.size.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", target, t)
		for button in [$SelConquest/Button2, $SelConquest/Button4, $SelConquest/Button6, $SelConquest/Button8]:
			target = Vector2(size.x, button.position.y)
			t = (size.x - button.position.x) / button_moving_speed / 2
			tween.parallel().tween_property(button, ^"position", target, t)
		tween.tween_callback(_move_button.bind(5))
		# NOTTODO: show more game button and mail button and refresh new highlight
		for button in [$SelConquest/Button1, $SelConquest/Button3, $SelConquest/Button5, $SelConquest/Button7]:
			tween.tween_property(button, ^"position", button.position, 0)
		for button in [$SelConquest/Button2, $SelConquest/Button4, $SelConquest/Button6, $SelConquest/Button8]:
			tween.tween_property(button, ^"position", button.position, 0)
		tween.tween_callback(_move_button.bind(0))
