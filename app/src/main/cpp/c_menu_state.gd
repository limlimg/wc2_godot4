extends "res://app/src/main/cpp/c_base_state.gd"

const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")

@onready var _gui_main_menu: Control = $GUIManager/GUIMainMenu

func _on_enter() -> void:
	var sound_box := _CSoundBox.get_instance()
	sound_box.load_music("battle1.mp3", "")
	sound_box.play_music(true)
	if g_GameManager.should_show_next_battle:
		_gui_main_menu.hide()
		var gui_sel_battle: Control = $GUIManager/GUISelBattle
		gui_sel_battle.campaign = g_GameManager.campaign
		gui_sel_battle.game_mode = 0
		g_GameManager.should_show_next_battle = false
	$GUIManager.fade_in(100)


func _on_gui_manager_faded_in(_cause: int) -> void:
	_gui_main_menu.move_in_main_buttons()
