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
var _num_moving_button := 0

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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		if _num_moving_button == 0:
			for button in [$SelCampaigns/ButtonBack, $SelConquest/ButtonBack]:
				if button.visible:
					button.pressed.emit()
					break
		get_viewport().set_input_as_handled()


func _on_button_campaign_pressed() -> void:
	# NOTTODO: hide more game and mail button
	move_button(2)
	_CSoundBox.get_instance().play_se("main_interface.wav")


func move_button(type: int) -> void:
	var tween: Tween
	var t: float
	if type == 1:
		var main_button: Control = $MainButtonContainer
		var target := Vector2(size.x - main_button.size.x, main_button.position.y)
		t = main_button.size.x / button_moving_speed
		_move_button_start()
		tween = create_tween()
		tween.tween_property(main_button, ^"position", target, t)
		tween.tween_callback(_move_button_completed)
	if type == 2:
		var main_button: Control = $MainButtonContainer
		var target := Vector2(size.x, main_button.position.y)
		t = (size.x - main_button.position.x) / button_moving_speed
		_move_button_start()
		tween = create_tween()
		tween.tween_property(main_button, ^"position", target, t)
		tween.tween_callback(move_button.bind(3))
		tween.tween_callback(_move_button_completed)
	elif type == 3:
		$SelCampaigns.show()
		for button in [$SelCampaigns/ButtonAxis, $SelCampaigns/ButtonWto]:
			_move_button_start()
			t = (button.position.x + button.size.x) / button_moving_speed
			tween = create_tween()
			tween.tween_property(button, ^"position", button.position, t)
			tween.tween_callback(_move_button_completed)
			button.position = Vector2(-button.size.x, button.position.y)
		for button in [$SelCampaigns/ButtonAllies, $SelCampaigns/ButtonNato]:
			_move_button_start()
			t = (size.x - button.position.x) / button_moving_speed
			tween = create_tween()
			tween.tween_property(button, ^"position", button.position, t)
			tween.tween_callback(_move_button_completed)
			button.position = Vector2(size.x, button.position.y)


func _move_button_start() -> void:
	_num_moving_button += 1


func _move_button_completed() -> void:
	_num_moving_button -= 1
