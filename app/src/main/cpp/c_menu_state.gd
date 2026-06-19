extends "res://app/src/main/cpp/c_base_state.gd"

const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")

func _on_enter() -> void:
	var sound_box := _CSoundBox.get_instance()
	sound_box.load_music("battle1.mp3", "")
	sound_box.play_music(true)
	if g_GameManager.should_show_next_battle:
		$GUIManager/GUIMainMenu.hide()
		$GUIManager/GUISelBattle.campaign = g_GameManager.campaign
		$GUIManager/GUISelBattle.game_mode = 0
		$GUIManager/GUISelBattle.show()
		g_GameManager.should_show_next_battle = false
	$GUIManager.fade_in(100)
	$GUIManager.faded_in.connect(func(cause: int):
		if cause == 100:
			$GUIManager/GUIMainMenu.move_in_main_buttons()
		, CONNECT_ONE_SHOT)


func _on_exit() -> void:
	_CSoundBox.get_instance().unload_music()


func _on_gui_main_menu_sel_campaign_pressed(sel_campaign: int) -> void:
	if (sel_campaign == 2 or sel_campaign == 3)\
		and g_Commander.get_num_played_battles(0) < _native.get_num_battles(0)\
		and g_Commander.get_num_played_battles(1) < _native.get_num_battles(1):
		$GUIManager/GUILockedWarning.show()
	else:
		$GUIManager.fade_out(3, $Prototype/GUILoading.duplicate())
		$GUIManager.faded_out.connect(func(cause: int):
			if cause == 3:
				$GUIManager/GUIMainMenu.hide()
				$GUIManager/GUISelBattle.campaign = sel_campaign
				$GUIManager/GUISelBattle.game_mode = 0
				$GUIManager/GUISelBattle.show()
				$GUIManager.fade_in(-1)
			, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_locked_warning_pressed() -> void:
	$GUIManager/GUILockedWarning.hide()


func _on_gui_main_menu_load_campaign_pressed() -> void:
	$GUIManager.fade_out(2, null)
	$GUIManager.faded_out.connect(func(cause: int):
		if cause == 2:
			$GUIManager/GUIMainMenu.hide()
			$GUIManager/GUISave.game_mode = 1
			$GUIManager/GUISave.loading = true
			$GUIManager/GUISave.show()
			$GUIManager.fade_in(-1)
		, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_main_menu_sel_conquest_pressed(sel_conquest: int) -> void:
	$GUIManager.fade_out(4, $Prototype/GUILoading.duplicate())
	$GUIManager.faded_out.connect(func(cause: int):
		if cause == 4:
			$GUIManager/GUIMainMenu.hide()
			$GUIManager/GUISelCountry.conquest = sel_conquest
			$GUIManager/GUISelCountry.show()
			$GUIManager.fade_in(-1)
		, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_main_menu_load_conquest_pressed() -> void:
	$GUIManager.fade_out(21, null)
	$GUIManager.faded_out.connect(func(cause: int):
		if cause == 21:
			$GUIManager/GUIMainMenu.hide()
			$GUIManager/GUISave.game_mode = 2
			$GUIManager/GUISave.loading = true
			$GUIManager/GUISave.show()
			$GUIManager.fade_in(-1)
		, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_main_menu_tutorial_pressed() -> void:
	$GUIManager.fade_out(14, null)
	$GUIManager.faded_out.connect(func(cause: int):
		if cause == 14:
			pass
		, ConnectFlags.CONNECT_ONE_SHOT)


func _on_gui_main_menu_commander_pressed() -> void:
	$GUIManager.fade_out(11, null)
	$GUIManager.faded_out.connect(func(cause: int):
		if cause == 11:
			$GUIManager/GUICommander.show()
			$GUIManager.fade_in(-1)
		, ConnectFlags.CONNECT_ONE_SHOT)


func _fade_out_back() -> void:
	$GUIManager.fade_out(9, null)
	$GUIManager.faded_out.connect(func(cause: int):
		if cause == 9:
			$GUIManager/GUIMainMenu.show()
			$GUIManager/GUISelBattle.hide()
			$GUIManager/GUISelCountry.hide()
			$GUIManager/GUISave.hide()
			$GUIManager/GUICommander.hide()
			$GUIManager.fade_in(-1)
		, CONNECT_ONE_SHOT)
