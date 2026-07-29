extends CBaseState

var _fade_order := 0
var _displayed_menu: Control
var _main_menu: Control

func _on_enter() -> void:
	var sound_box := CSoundBox.get_instance()
	sound_box.load_music("battle1.mp3", "")
	sound_box.play_music(true)
	var gui_manager := GUIManager.instance()
	_main_menu = $GUIMainMenu.create_instance()
	_main_menu.sel_campaign_pressed.connect(_on_gui_main_menu_sel_campaign_pressed)
	_main_menu.load_campaign_pressed.connect(_on_gui_main_menu_load_campaign_pressed)
	_main_menu.sel_conquest_pressed.connect(_on_gui_main_menu_sel_conquest_pressed)
	_main_menu.load_conquest_pressed.connect(_on_gui_main_menu_load_conquest_pressed)
	#_main_menu.multi_player_global_pressed.connect(_on_gui_main_menu_multi_player_global_pressed)
	#_main_menu.multi_player_host_pressed.connect(_on_gui_main_menu_multi_player_host_pressed)
	#_main_menu.multi_player_join_pressed.connect(_on_gui_main_menu_multi_player_join_pressed)
	_main_menu.tutorial_pressed.connect(_on_gui_main_menu_tutorial_pressed)
	_main_menu.commander_pressed.connect(_on_gui_main_menu_commander_pressed)
	_main_menu.options_pressed.connect(_on_gui_main_menu_options_pressed)
	_main_menu.quit_pressed.connect(_on_gui_main_menu_quit_pressed)
	_main_menu.reparent(gui_manager)
	if g_GameManager.should_show_next_battle:
		_main_menu.hide()
		if _displayed_menu != null:
			GUIManager.instance().safe_free_child(_displayed_menu)
		_displayed_menu = $GUISelBattle.create_instance()
		_displayed_menu.campaign = g_GameManager.campaign
		_displayed_menu.game_mode = 0
		_displayed_menu.show()
		_displayed_menu.back_pressed.connect(_fade_out_back)
		_displayed_menu.ok_pressed.connect(_fade_out_load_state)
		_displayed_menu.reparent(gui_manager)
		g_GameManager.should_show_next_battle = false
	_fade_order += 1
	var wait_fade_order := _fade_order
	GUIManager.instance().fade_in(100)
	var cause: int = await GUIManager.instance().faded_in
	if cause == 100 and _fade_order == wait_fade_order:
		_main_menu.move_in_main_buttons()


func _on_exit() -> void:
	CSoundBox.get_instance().unload_music()
	GUIManager.instance().free_all_child()


func _back_pressed() -> bool:
	show_exit()
	return true


func show_exit() -> void:
	if _displayed_menu == null:
		_displayed_menu = $GUIExitWarning.create_instance()
		_displayed_menu.show()
		_displayed_menu.cancelled.connect(_on_gui_exit_warning_cancelled)
		_displayed_menu.reparent(GUIManager.instance())


func _on_gui_main_menu_sel_campaign_pressed(sel_campaign: int) -> void:
	if (sel_campaign == 2 or sel_campaign == 3)\
		and g_Commander.get_num_played_battles(0) < AppDelegate.get_num_battles(0)\
		and g_Commander.get_num_played_battles(1) < AppDelegate.get_num_battles(1):
		if _displayed_menu != null:
			GUIManager.instance().safe_free_child(_displayed_menu)
		_displayed_menu = $GUILockedWarning.create_instance()
		_displayed_menu.pressed.connect(_on_gui_locked_warning_pressed)
		_displayed_menu.show()
		_displayed_menu.reparent(GUIManager.instance())
	else:
		_fade_order += 1
		var wait_fade_order := _fade_order
		GUIManager.instance().fade_out(3, $GUILoading.create_instance())
		var cause: int = await GUIManager.instance().faded_out
		if cause == 3 and _fade_order == wait_fade_order:
			_main_menu.hide()
			if _displayed_menu != null:
				GUIManager.instance().safe_free_child(_displayed_menu)
			_displayed_menu = $GUISelBattle.create_instance()
			_displayed_menu.campaign = sel_campaign
			_displayed_menu.game_mode = 0
			_displayed_menu.show()
			_displayed_menu.back_pressed.connect(_fade_out_back)
			_displayed_menu.ok_pressed.connect(_fade_out_load_state)
			_displayed_menu.reparent(GUIManager.instance())
			GUIManager.instance().fade_in(-1)


func _on_gui_locked_warning_pressed() -> void:
	GUIManager.instance().safe_free_child(_displayed_menu)


func _on_gui_main_menu_load_campaign_pressed() -> void:
	_fade_order += 1
	var wait_fade_order := _fade_order
	GUIManager.instance().fade_out(2, null)
	var cause: int = await GUIManager.instance().faded_out
	if cause == 2 and _fade_order == wait_fade_order:
		_main_menu.hide()
		if _displayed_menu != null:
			GUIManager.instance().safe_free_child(_displayed_menu)
		_displayed_menu = $GUISave.create_instance()
		_displayed_menu.game_mode = 1
		_displayed_menu.loading = true
		_displayed_menu.show()
		_displayed_menu.back_pressed.connect(_fade_out_back)
		_displayed_menu.ok_pressed.connect(_fade_out_load_state)
		_displayed_menu.reparent(GUIManager.instance())
		GUIManager.instance().fade_in(-1)


func _on_gui_main_menu_sel_conquest_pressed(sel_conquest: int) -> void:
	_fade_order += 1
	var wait_fade_order := _fade_order
	GUIManager.instance().fade_out(4, $GUILoading.create_instance())
	var cause: int = await GUIManager.instance().faded_out
	if cause == 4 and _fade_order == wait_fade_order:
		_main_menu.hide()
		if _displayed_menu != null:
			GUIManager.instance().safe_free_child(_displayed_menu)
		_displayed_menu = $GUISelCountry.create_instance()
		_displayed_menu.conquest = sel_conquest
		_displayed_menu.show()
		_displayed_menu.back_pressed.connect(_fade_out_back)
		_displayed_menu.ok_pressed.connect(_fade_out_load_state)
		_displayed_menu.reparent(GUIManager.instance())
		GUIManager.instance().fade_in(-1)


func _on_gui_main_menu_load_conquest_pressed() -> void:
	_fade_order += 1
	var wait_fade_order := _fade_order
	GUIManager.instance().fade_out(21, null)
	var cause: int = await GUIManager.instance().faded_out
	if cause == 21 and _fade_order == wait_fade_order:
		_main_menu.hide()
		if _displayed_menu != null:
			GUIManager.instance().safe_free_child(_displayed_menu)
		_displayed_menu = $GUISave.create_instance()
		_displayed_menu.game_mode = 2
		_displayed_menu.loading = true
		_displayed_menu.show()
		_displayed_menu.back_pressed.connect(_fade_out_back)
		_displayed_menu.ok_pressed.connect(_fade_out_load_state)
		_displayed_menu.reparent(GUIManager.instance())
		GUIManager.instance().fade_in(-1)


func _on_gui_main_menu_tutorial_pressed() -> void:
	g_GameManager.new_game(5, 0, 0, 0)
	_fade_out_load_state()


func _fade_out_load_state() -> void:
	_fade_order += 1
	var wait_fade_order := _fade_order
	GUIManager.instance().fade_out(14, null)
	var cause: int = await GUIManager.instance().faded_out
	if cause == 14 and _fade_order == wait_fade_order:
		CStateManager.instance().set_cur_state(EState.LOAD)


func _on_gui_main_menu_commander_pressed() -> void:
	_fade_order += 1
	var wait_fade_order := _fade_order
	GUIManager.instance().fade_out(11, null)
	var cause: int = await GUIManager.instance().faded_out
	if cause == 11 and _fade_order == wait_fade_order:
		_main_menu.hide()
		if _displayed_menu != null:
			GUIManager.instance().safe_free_child(_displayed_menu)
		_displayed_menu = $GUICommander.create_instance()
		_displayed_menu.show()
		_displayed_menu.back_pressed.connect(_fade_out_back)
		_displayed_menu.reparent(GUIManager.instance())
		GUIManager.instance().fade_in(-1)


func _on_gui_main_menu_options_pressed() -> void:
	_fade_order += 1
	var wait_fade_order := _fade_order
	GUIManager.instance().fade_out(12, null)
	var cause: int = await GUIManager.instance().faded_out
	if cause == 12 and _fade_order == wait_fade_order:
		_main_menu.hide()
		if _displayed_menu != null:
			GUIManager.instance().safe_free_child(_displayed_menu)
		_displayed_menu = $GUIOptions.create_instance()
		_displayed_menu.show()
		_displayed_menu.closed.connect(_fade_out_back)
		_displayed_menu.reparent(GUIManager.instance())
		GUIManager.instance().fade_in(-1)


func _on_gui_main_menu_quit_pressed() -> void:
	show_exit()


func _fade_out_back() -> void:
	_fade_order += 1
	var wait_fade_order := _fade_order
	GUIManager.instance().fade_out(9, null)
	var cause: int = await GUIManager.instance().faded_out
	if cause == 9 and _fade_order == wait_fade_order:
		_main_menu.show()
		GUIManager.instance().safe_free_child(_displayed_menu)
		GUIManager.instance().fade_in(-1)


func _on_gui_exit_warning_cancelled() -> void:
	_displayed_menu.hide()
	GUIManager.instance().safe_free_child(_displayed_menu)
