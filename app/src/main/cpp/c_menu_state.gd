extends "res://app/src/main/cpp/c_base_state.gd"

const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _CStateManager = preload("res://app/src/main/cpp/c_state_manager.gd")

var _displayed_menu: Control

func _on_enter() -> void:
	var sound_box := _CSoundBox.get_instance()
	sound_box.load_music("battle1.mp3", "")
	sound_box.play_music(true)
	if g_GameManager.should_show_next_battle:
		$GUIManager/GUIMainMenu.hide()
		_displayed_menu = $GUIManager/GUISelBattle.create_instance()
		_displayed_menu.campaign = g_GameManager.campaign
		_displayed_menu.game_mode = 0
		_displayed_menu.show()
		_displayed_menu.back_pressed.connect(_fade_out_back)
		_displayed_menu.ok_pressed.connect(_fade_out_load_state)
		g_GameManager.should_show_next_battle = false
	$GUIManager.fade_in(100)
	$GUIManager.faded_in.connect(func(cause: int):
		if cause == 100:
			$GUIManager/GUIMainMenu.move_in_main_buttons()
		, CONNECT_ONE_SHOT)


func _on_exit() -> void:
	_CSoundBox.get_instance().unload_music()


func _back_pressed() -> bool:
	show_exit()
	return true


func show_exit() -> void:
	if _displayed_menu == null:
		_displayed_menu = $GUIManager/GUIExitWarning.create_instance()
		_displayed_menu.show()
		_displayed_menu.cancelled.connect(_on_gui_exit_warning_cancelled)


func _on_gui_main_menu_sel_campaign_pressed(sel_campaign: int) -> void:
	if (sel_campaign == 2 or sel_campaign == 3)\
		and g_Commander.get_num_played_battles(0) < _native.get_num_battles(0)\
		and g_Commander.get_num_played_battles(1) < _native.get_num_battles(1):
		_displayed_menu = $GUIManager/GUILockedWarning.create_instance()
		_displayed_menu.pressed.connect(_on_gui_locked_warning_pressed)
		_displayed_menu.show()
	else:
		$GUIManager.fade_out(3, $Prototype/GUILoading.create_instance())
		$GUIManager.faded_out.connect(func(cause: int):
			if cause == 3:
				$GUIManager/GUIMainMenu.hide()
				_displayed_menu = $GUIManager/GUISelBattle.create_instance()
				_displayed_menu.campaign = sel_campaign
				_displayed_menu.game_mode = 0
				_displayed_menu.show()
				_displayed_menu.back_pressed.connect(_fade_out_back)
				_displayed_menu.ok_pressed.connect(_fade_out_load_state)
				$GUIManager.fade_in(-1)
			, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_locked_warning_pressed() -> void:
	_displayed_menu.hide()


func _on_gui_main_menu_load_campaign_pressed() -> void:
	$GUIManager.fade_out(2, null)
	$GUIManager.faded_out.connect(func(cause: int):
		if cause == 2:
			$GUIManager/GUIMainMenu.hide()
			_displayed_menu = $GUIManager/GUISave.create_instance()
			_displayed_menu.game_mode = 1
			_displayed_menu.loading = true
			_displayed_menu.show()
			_displayed_menu.back_pressed.connect(_fade_out_back)
			_displayed_menu.ok_pressed.connect(_fade_out_load_state)
			$GUIManager.fade_in(-1)
		, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_main_menu_sel_conquest_pressed(sel_conquest: int) -> void:
	$GUIManager.fade_out(4, $Prototype/GUILoading.create_instance())
	$GUIManager.faded_out.connect(func(cause: int):
		if cause == 4:
			$GUIManager/GUIMainMenu.hide()
			_displayed_menu = $GUIManager/GUISelCountry.create_instance()
			_displayed_menu.conquest = sel_conquest
			_displayed_menu.show()
			_displayed_menu.back_pressed.connect(_fade_out_back)
			_displayed_menu.ok_pressed.connect(_fade_out_load_state)
			$GUIManager.fade_in(-1)
		, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_main_menu_load_conquest_pressed() -> void:
	$GUIManager.fade_out(21, null)
	$GUIManager.faded_out.connect(func(cause: int):
		if cause == 21:
			$GUIManager/GUIMainMenu.hide()
			_displayed_menu = $GUIManager/GUISave.create_instance()
			_displayed_menu.game_mode = 2
			_displayed_menu.loading = true
			_displayed_menu.show()
			_displayed_menu.back_pressed.connect(_fade_out_back)
			_displayed_menu.ok_pressed.connect(_fade_out_load_state)
			$GUIManager.fade_in(-1)
		, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_main_menu_tutorial_pressed() -> void:
	g_GameManager.new_game(5, 0, 0, 0)
	_fade_out_load_state()


func _fade_out_load_state() -> void:
	$GUIManager.fade_out(14, null)
	$GUIManager.faded_out.connect(func(cause: int):
		if cause == 14:
			_CStateManager.instance().set_cur_state("res://app/src/main/cpp/c_load_state.tscn")
		, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_main_menu_commander_pressed() -> void:
	$GUIManager.fade_out(11, null)
	$GUIManager.faded_out.connect(func(cause: int):
		if cause == 11:
			$GUIManager/GUIMainMenu.hide()
			_displayed_menu = $GUIManager/GUICommander.create_instance()
			_displayed_menu.show()
			_displayed_menu.back_pressed.connect(_fade_out_back)
			$GUIManager.fade_in(-1)
		, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_main_menu_options_pressed() -> void:
	$GUIManager.fade_out(12, null)
	$GUIManager.faded_out.connect(func(cause: int):
		if cause == 12:
			$GUIManager/GUIMainMenu.hide()
			_displayed_menu = $GUIManager/GUIOptions.create_instance()
			_displayed_menu.show()
			_displayed_menu.closed.connect(_fade_out_back)
			$GUIManager.fade_in(-1)
		, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_main_menu_quit_pressed() -> void:
	show_exit()


func _fade_out_back() -> void:
	$GUIManager.fade_out(9, null)
	$GUIManager.faded_out.connect(func(cause: int):
		if cause == 9:
			$GUIManager/GUIMainMenu.show()
			$GUIManager.safe_free_child(_displayed_menu)
			$GUIManager.fade_in(-1)
		, CONNECT_ONE_SHOT)


func _on_gui_exit_warning_cancelled() -> void:
	_displayed_menu.hide()
	$GUIManager.safe_free_child(_displayed_menu)
