extends "res://app/src/main/cpp/c_base_state.gd"

const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")

var _sel_campaign: int

@onready var _gui_main_menu: Control = $GUIManager/GUIMainMenu
@onready var _gui_manager: _GUIManager = $GUIManager
@onready var _gui_sel_battle: Control = $GUIManager/GUISelBattle
@onready var _gui_locked_warning: Control = $GUIManager/GUILockedWarning

func _on_enter() -> void:
	var sound_box := _CSoundBox.get_instance()
	sound_box.load_music("battle1.mp3", "")
	sound_box.play_music(true)
	if g_GameManager.should_show_next_battle:
		_gui_main_menu.hide()
		_gui_sel_battle.campaign = g_GameManager.campaign
		_gui_sel_battle.game_mode = 0
		_gui_sel_battle.show()
		g_GameManager.should_show_next_battle = false
	_gui_manager.fade_in(100)
	_gui_manager.faded_in.connect(func(cause: int):
		if cause == 100:
			_gui_main_menu.move_in_main_buttons()
		, CONNECT_ONE_SHOT)


func _on_exit() -> void:
	_CSoundBox.get_instance().unload_music()


func _on_gui_main_menu_sel_campaign_pressed(sel_campaign: int) -> void:
	if (sel_campaign == 2 or sel_campaign == 3)\
		and g_Commander.get_num_played_battles(0) < _native.get_num_battles(0)\
		and g_Commander.get_num_played_battles(1) < _native.get_num_battles(1):
		_gui_locked_warning.show()
	else:
		var loading: Node = load("res://app/src/main/cpp/gui_loading.tscn").instantiate()
		_gui_manager.fade_out(3, loading)
		_sel_campaign = sel_campaign
		_gui_manager.faded_out.connect(func(cause: int):
			if cause == 3:
				_gui_main_menu.hide()
				_gui_sel_battle.campaign = _sel_campaign
				_gui_sel_battle.game_mode = 0
				_gui_sel_battle.show()
				_gui_manager.fade_in(-1)
			, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_sel_battle_back_pressed() -> void:
	_gui_manager.fade_out(9, null)
	_gui_manager.faded_out.connect(func(cause: int):
		if cause == 9:
			_gui_main_menu.show()
			_gui_sel_battle.hide()
			_gui_manager.fade_in(-1)
		, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_locked_warning_pressed() -> void:
	_gui_locked_warning.hide()
