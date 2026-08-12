class_name CGameState
extends CBaseState

var _first_touch: bool
var _second_touch: bool
var _first_touch_pos: Vector2
var _second_touch_pos: Vector2
var _first_touch_index: int
var _second_touch_index: int
var _button_round: Control
var _button_card: Control
var _button_pause: Control
var _button_card_remove: Control
var _buying_card: bool
var _gui_gold: Control
var _gui_tax: Control
var _gui_small_card: Control
var _gui_attack_box: Control
var _gui_pause_box: Control
var _gui_buy_card: GUIBuyCard
var _gui_ai_progress: Control
var _gui_sel_army: Control
var _gui_begin: Control
var _gui_action_info: Control
var _gui_defeated: Control
var _gui_battle: Control
var _gui_tutorials: Control
var _gui_dialogue: Control
var _gui_battle_intro: Control
var _gui_bank: Control
var _gui_victory: Control
var _gui_result: Control
var _gui_end: Control
var _gui_options: Control
var _gui_save: Control
var _gui_warning: Control
var _motion: Array
var _game_running: bool
var _set_auto_fix_position: bool

func init_game() -> void:
	g_SoundRes.load_res()
	g_FightTextMgr.init()
	g_GameRes.load_res()
	if EC2dAppDelegate.g_content_scale_factor == 2.0:
		GUIManager.instance().load_texture_res("cardtex_hd.xml", true)
	else:
		GUIManager.instance().load_texture_res("cardtex.xml", false)
	g_GameManager.init_battle()
	$CTouchInertia.init()


func _on_enter() -> void:
	var gui_manager := GUIManager.instance()
	gui_manager.event_receiver = $IEventReceiver
	GUIMotionManager.instance().event_receiver = $IEventReceiver
	_button_round = $ButtonRound.create_instance()
	_button_round.pressed.connect(_on_button_round_pressed)
	_button_card = $ButtonCard.create_instance()
	_button_card.pressed.connect(_on_button_card_pressed)
	_button_pause = $ButtonPause.create_instance()
	_button_pause.pressed.connect(_on_button_pause_pressed)
	_button_card_remove = $ButtonCardRemove.create_instance()
	_button_card_remove.pressed.connect(_on_button_card_remove_pressed)
	_gui_gold = $GUIGold.create_instance()
	_gui_tax = $GUITax.create_instance()
	_gui_small_card = $GUISmallCard.create_instance()
	_gui_attack_box = $GUIAttackBox.create_instance()
	_gui_attack_box.ok_pressed.connect(_on_gui_attack_box_ok_pressed)
	_gui_pause_box = $GUIPauseBox.create_instance()
	_gui_pause_box.options_pressed.connect(_on_gui_pause_box_options_pressed)
	_gui_pause_box.save_pressed.connect(_on_gui_pause_box_save_pressed)
	_gui_pause_box.restart_pressed.connect(_on_gui_pause_box_restart_pressed)
	_gui_pause_box.quit_pressed.connect(_on_gui_pause_box_quit_pressed)
	_gui_buy_card = $GUIBuyCard.create_instance()
	_gui_buy_card.back_pressed.connect(_on_gui_buy_card_back_pressed)
	_gui_buy_card.ok_pressed.connect(_on_gui_buy_card_ok_pressed)
	_gui_ai_progress = $GUIAIProgress.create_instance()
	var cur_country = g_GameManager.get_cur_country()
	if cur_country != null and not cur_country.ai:
		_gui_ai_progress.hide()
	else:
		_update_ai_progress()
		if g_GameManager.game_mode == 4:
			_gui_ai_progress.hide()
	_gui_sel_army = $GUISelArmy.create_instance()
	_gui_sel_army.army_targeted.connect(_on_gui_sel_army_army_targeted)
	_gui_begin = $GUIBegin.create_instance()
	_gui_begin.ok_pressed.connect(_on_gui_begin_ok_pressed)
	_gui_begin.bank_pressed.connect(_on_gui_begin_bank_pressed)
	_gui_options = null
	_gui_save = null
	_gui_result = null
	_gui_battle_intro = null
	_gui_victory = null
	_gui_bank = null
	_gui_end = null
	_gui_warning = null
	if g_GameManager.game_mode == 4:
		_gui_action_info = $GUIActionInfo.create_instance()
	else:
		_gui_action_info = null
	_gui_defeated = $GUIDefeated.create_instance()
	_gui_defeated.ok_pressed.connect(_on_gui_defeated_ok_pressed)
	_gui_battle = $GUIBattle.create_instance()
	_gui_battle.reparent(gui_manager)
	_gui_defeated.reparent(gui_manager)
	if _gui_action_info != null:
		_gui_action_info.reparent(gui_manager)
	_gui_sel_army.reparent(gui_manager)
	_gui_ai_progress.reparent(gui_manager)
	_gui_buy_card.reparent(gui_manager)
	_gui_pause_box.reparent(gui_manager)
	_gui_small_card.reparent(gui_manager)
	_gui_tax.reparent(gui_manager)
	_gui_gold.reparent(gui_manager)
	_button_card_remove.reparent(gui_manager)
	_button_pause.reparent(gui_manager)
	_button_card.reparent(gui_manager)
	_button_round.reparent(gui_manager)
	_gui_attack_box.reparent(gui_manager)
	_gui_begin.reparent(gui_manager)
	if g_GameManager.game_mode == 5:
		_gui_tutorials = $GUITutorails.create_instance()
		_gui_tutorials.reparent(gui_manager)
		_gui_dialogue = null
	else:
		_gui_tutorials = null
		_gui_dialogue = $GUIDialogue.create_instance()
		_gui_dialogue.pressed.connect(_on_gui_dialogue_pressed)
		_gui_dialogue.reparent(gui_manager)
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	_motion.resize(4)
	var motion := GUIMotionManager.instance()
	var target := _button_round.position - _button_round.size
	_motion[0] = motion.add_motion_from_current_position(_button_round, target.x, target.y, 3.0, 0)
	target = _button_card.position - _button_card.size
	_motion[1] = motion.add_motion_from_current_position(_button_card, 0.0, target.y, 3.0, 0)
	target = _button_pause.position - _button_pause.size
	_motion[2] = motion.add_motion_from_current_position(_button_pause, target.x, 0.0, 3.0, 0)
	_motion[3] = motion.add_motion_from_current_position(_gui_gold, 0.0, 0.0, 3.0, 0)
	CSoundBox.get_instance().load_music("battle{0}.mp3".format([randi_range(1, 4)]), "")
	CSoundBox.get_instance().play_music(true)
	GUIManager.instance().fade_in(1)
	_buying_card = false
	_game_running = false
	if g_GameManager.is_new_game and g_GameManager.game_mode != 4:
		g_GameManager.turn_begin()


func _update_ai_progress() -> void:
	var cur_country = g_GameManager.get_cur_country()
	if cur_country != null and not cur_country.ai:
		_gui_ai_progress.set_cur_country_name(cur_country.name)
		_gui_ai_progress.progress = CActionAI.instance().ai_progress_percentage


func _on_i_event_receiver_faded_in(_cause: int) -> void:
	if g_GameManager.game_mode == 1:
		_gui_battle_intro = $GUIBattleIntro.create_instance()
		_gui_battle_intro.ok_pressed.connect(_on_gui_battle_intro_ok_pressed)
		_gui_battle_intro.reparent(GUIManager.instance())
		_gui_battle_intro.campaign = g_GameManager.campaign
		_gui_battle_intro.battle = g_GameManager.battle
	else:
		var motion := GUIMotionManager.instance()
		for i in _motion:
			motion.active_motion(i, 0)
	if g_GameManager.game_mode == 4:
		# TODO: send multiplayer data
		pass


func _on_i_event_receiver_motion_finished(index: int) -> void:
	if index == 1:
		_game_running = true


func _on_i_event_receiver_faded_out(cause: int) -> void:
	match cause:
		9:
			CStateManager.instance().set_cur_state(EState.MENU)
		14:
			CStateManager.instance().set_cur_state(EState.LOAD)
		20:
			_gui_result.queue_free()
			_gui_result = null
			_gui_end = $GUIEnd.create_instance()
			_gui_end.reparent(GUIManager.instance())
			GUIManager.instance().fade_in(-1)


func _on_exit() -> void:
	if not g_GameManager.game_ended:
		if g_GameManager.game_mode == 2:
			g_GameManager.save_game("conquest6.sav")
		else:
			g_GameManager.save_game("game6.sav")
	CSoundBox.get_instance().unload_music()
	GUIMotionManager.instance().clear_motion()
	GUIManager.instance().free_all_child()
	_release_game()
	if g_GameManager.game_mode == 4:
		# TODO: multiplayer
		pass
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP


func _release_game() -> void:
	g_Scene.release()
	if EC2dAppDelegate.g_content_scale_factor == 2.0:
		GUIManager.instance().unload_texture_res("cardtex_hd.xml")
	else:
		GUIManager.instance().unload_texture_res("cardtex.xml")
	g_GameRes.release()
	g_FightTextMgr.release()
	g_SoundRes.unload_res()


func _process(delta: float) -> void:
	# The idle timer does not seem to do anything?
	var country = g_GameManager.get_cur_country()
	if not _gui_battle.visible:
		if g_GameSettings.speed > 2 and country != null and country.ai:
			delta *= g_GameSettings.speed / 2.0
	if g_GameManager.game_mode == 4:
		# TODO: if not local player?
		delta *= 1.1
	if _buying_card:
		if g_GameManager.get_player_country().is_action_finished():
			if _gui_buy_card.can_buy_sel_card():
				_gui_buy_card.reset_card_target()
			else:
				_gui_buy_card.release_target()
				_button_card_remove.hide()
				_button_card.show()
				_gui_small_card.hide()
			_buying_card = false
	if _gui_pause_box.visible\
		or (_gui_options != null and _gui_options.visible)\
		or (_gui_save != null and _gui_save.visible)\
		or (_gui_warning != null and _gui_warning.visible)\
		or (_gui_dialogue != null and _gui_dialogue.visible):
		return
	if g_GameManager.is_manipulate():
		$CTouchInertia.update(delta)
		var speed = $CTouchInertia.get_speed()
		if speed != Vector2.ZERO:
			if g_Scene.move(-speed.x * delta, -speed.y * delta):
				$CTouchInertia.stop()
		elif _set_auto_fix_position:
			g_Scene.camera.set_auto_fix_pos(true)
			_set_auto_fix_position = false
	ecEffectManager.instance().update(delta)
	g_Scene.update(delta)
	g_FightTextMgr.update(delta)
	if (_gui_defeated != null and _gui_defeated.visible)\
		or _gui_battle.visible or g_Scene.is_bombing() or not _game_running:
		return
	if g_GameManager.game_mode == 4:
		# TODO: multiplayer
		pass
	g_GameManager.game_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			# touch begin
			# ecMultipleTouch is not running in this port
			if not _first_touch:
				_first_touch_index = event.index
				_first_touch = true
				_first_touch_pos = event.position
				$CTouchInertia.touch_begin(event.position.x, event.position.y, event.index)
			elif not _second_touch:
				_second_touch_index = event.index
				_second_touch = true
				_second_touch_pos = event.position
			g_Scene.camera.set_auto_fix_pos(false)
			_set_auto_fix_position = false
		else:
			# touch end
			if event.index == _first_touch_index:
				_first_touch = false
			elif event.index == _second_touch_index:
				_second_touch = false
			_set_auto_fix_position = true
			if not $CTouchInertia.touch_end(event.position.x, event.position.y, event.index):
				return
			if not g_GameManager.is_manipulate():
				return
			g_Scene.flashing_turn_begin = false
			var area = g_Scene.screen_to_area(event.position.x, event.position.y)
			if area == null:
				return
			var selected_area = g_Scene.get_selected_area()
			var card = _gui_buy_card.get_sel_card()
			if card == null or not _gui_buy_card.targeting or _buying_card:
				if selected_area != null:
					if area == selected_area:
						g_Scene.unselect_area()
						g_SoundRes.play_char_se(SND_EFFECT.CANCEL_WAV)
						_gui_tax.hide()
						_gui_sel_army.hide()
					elif selected_area.is_active() and selected_area.country == g_GameManager.get_cur_country():
						if selected_area.army_drafting or selected_area.army_moving_in or selected_area.army_moving_to_front:
							return
						if g_Scene.check_moveable(selected_area.id, area.id, 0):
							var action := CountryAction.new()
							action.type = 1
							action.start_area = selected_area.id
							action.army_index = 0
							action.target_area = area.id
							g_GameManager.get_player_country().action(action)
							if g_GameManager.game_mode == 4:
								# TODO: send multiplayer action
								pass
						elif g_Scene.check_attackable(selected_area.id, area.id, 0):
							_gui_attack_box.set_attack(selected_area.id, area.id)
							_gui_attack_box.show()
						g_Scene.unselect_area()
						_gui_tax.hide()
						_gui_sel_army.hide()
					else:
						g_Scene.unselect_area()
						_gui_sel_army.hide()
						g_Scene.select_area(area)
						_gui_tax.set_area(area.id)
						_gui_tax.show()
						if area.country == g_GameManager.get_cur_country() and area.get_num_armies() > 1:
							_gui_sel_army.set_area(area.id)
							_gui_sel_army.targeting = false
							_gui_sel_army.show()
						g_SoundRes.play_char_se(SND_EFFECT.SELECT_WAV)
				else:
					g_Scene.select_area(area)
					_gui_tax.set_area(area.id)
					_gui_tax.show()
					if area.country == g_GameManager.get_cur_country() and area.get_num_armies() > 1:
						_gui_sel_army.set_area(area.id)
						_gui_sel_army.targeting = false
						_gui_sel_army.show()
					g_SoundRes.play_char_se(SND_EFFECT.SELECT_WAV)
			else:
				var country = g_GameManager.get_cur_country()
				if not country.check_card_target_area(card, area.id):
					return
				var action := CountryAction.new()
				action.type = 5
				action.card_id = card.id
				action.target_area = area.id
				action.army_index = 0
				country.action(action)
				if g_GameManager.game_mode == 4:
					# TODO: send multiplayer action
					pass
				_buying_card = true
				_gui_tax.set_area(area.id)
	elif event is InputEventScreenDrag:
		# touch move
		$CTouchInertia.touch_move(event.position.x, event.position.y, event.index)
		if not g_GameManager.is_manipulate():
			return
		var d0: float
		if _first_touch and event.index == _first_touch_index:
			if _second_touch:
				d0 = _first_touch_pos.distance_squared_to(_second_touch_pos)
			_first_touch_pos = event.position
		elif _second_touch and event.index == _second_touch_index:
			if _first_touch:
				d0 = _first_touch_pos.distance_squared_to(_second_touch_pos)
			_second_touch_pos = event.position
		else:
			return
		if _first_touch and _second_touch:
			var d1 := _first_touch_pos.distance_squared_to(_second_touch_pos)
			if d1 <= 1600.0:
				return
			var camera_pos = g_Scene.camera.camera_position + event.relative / g_Scene.camera.camera_zoom / 2
			var camera_scale = g_Scene.camera.camera_zoom.length_squared() * d1 / d0 / 2
			g_Scene.camera.set_pos_and_scale(camera_pos.x, camera_pos.y, camera_scale)
		else:
			g_Scene.move(-event.relative.x, -event.relative.y)
	elif event is InputEventMouseButton:
		# scroll wheel
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			var pos = g_Scene.camera.camera_position
			var s = g_Scene.camera.camera_zoom.x + 0.1
			g_Scene.camera.set_pos_and_scale(pos.x, pos.y, s)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			var pos = g_Scene.camera.camera_position
			var s = g_Scene.camera.camera_zoom.x - 0.1
			g_Scene.camera.set_pos_and_scale(pos.x, pos.y, s)
	if event.is_action_released(&"ui_cancel"):
		# back pressed
		if g_GameManager.game_mode == 5:
			GUIManager.instance().fade_out(9, null)
		elif _gui_pause_box.visible:
			_gui_pause_box.hide()
		else:
			if not _gui_battle.visible:
				_reset_touch_state()
				_gui_pause_box.move_to_front()
				_gui_pause_box.show()
		get_viewport().set_input_as_handled()


func _reset_touch_state() -> void:
	_first_touch = false
	_second_touch = false
	$CTouchInertia.init()


func _enter_background() -> void:
	if not g_GameManager.game_ended:
		if g_GameManager.game_mode == 2:
			g_GameManager.save_game("conquest6.sav")
		else:
			g_GameManager.save_game("game6.sav")


func show_defeated(country: CCountry) -> void:
	_gui_defeated.move_to_front()
	_gui_defeated.show_defeated(country)


func start_battle(start_area: int, target_area: int, animated: bool) -> void:
	if _gui_battle == null:
		return
	if animated:
		ecEffectManager.instance().remove_all()
		_gui_battle.move_to_front()
		_gui_battle.show()
		_gui_battle.battle_start(start_area, target_area)
		# enable idle timer
	else:
		var fight := CFight.new()
		fight.first_attack(start_area, target_area)
		fight.apply_result()
		if fight.attack_army_second_attack or fight.defend_army_second_attack:
			fight.second_attack()
			fight.apply_result()


func hide_ai_progress() -> void:
	_gui_ai_progress.hide()
	_button_round.show()
	_button_card.show()
	# enable idle timer


func player_country_begin() -> void:
	_gui_begin.reset_data()
	_gui_begin.show()
	g_SoundRes.play_char_se(SND_EFFECT.POP_WAV)


func select_area(id: int) -> void:
	g_Scene.select_area(id)
	_gui_tax.set_area(id)
	_gui_tax.show()
	var area = g_Scene.get_area(id)
	if area.country == g_GameManager.get_cur_country() and area.get_num_armies() > 1:
		_gui_sel_army.set_area(id)
		_gui_sel_army.targeting = false
		_gui_sel_army.show()


func unselect_area() -> void:
	g_Scene.unselect_area()
	_gui_tax.hide()
	_gui_sel_army.hide()


func show_dialogue(dlg: String, general: StringName, left: bool) -> void:
	_gui_dialogue.show_dlg(dlg, general, left)


# TODO: show_warning (multiplayer)


func update_action_info() -> void:
	# TODO: multiplayer
	pass


func _on_gui_victory_time_passed() -> void:
	_gui_victory.queue_free()
	_gui_victory = null
	if _gui_result == null:
		if g_GameManager.game_won and g_GameManager.game_mode == 1:
			# ask for review?
			pass
		_gui_result = $GUIResult.create_instance()
		_gui_result.back_pressed.connect(_on_gui_result_back_pressed)
		_gui_result.next_pressed.connect(_on_gui_result_next_pressed)
		_gui_result.restart_pressed.connect(_on_gui_pause_box_restart_pressed)
		_gui_result.show_restart = not g_GameManager.game_won
		_gui_result.reparent(GUIManager.instance())


func _on_gui_sel_army_army_targeted(index: int) -> void:
	var action := CountryAction.new()
	action.type = 5
	action.target_area = _gui_sel_army.areaaccept_event()
	action.card_id = _gui_buy_card.get_sel_card().id
	action.army_index = index
	g_GameManager.get_cur_country().action(action)
	if g_GameManager.game_mode == 4:
		# TODO: send multiplayer action
		pass
	_buying_card = true


func _on_gui_battle_intro_ok_pressed() -> void:
	var motion := GUIMotionManager.instance()
	for i in _motion:
		motion.active_motion(i, 0)
	_gui_battle_intro.queue_free()
	_gui_battle_intro = null


func _on_gui_dialogue_pressed() -> void:
	if not g_GameManager.game_ended:
		var dlg = g_GameManager.get_cur_dialogue()
		if dlg != null and dlg.at_round <= g_GameManager.current_round + 1:
			var s = g_GameManager.get_cur_dialogue_string()
			show_dialogue(s, dlg.commander, dlg.left)
			g_GameManager.next_dialogue()
	elif _gui_victory == null:
		_gui_victory = $GUIVictory.create_instance()
		_gui_victory.time_passed.connect(_on_gui_victory_time_passed)
		_gui_victory.victorious = g_GameManager.game_won
		_gui_victory.reparent(GUIManager.instance())
		_gui_victory.play()


func _on_button_round_pressed() -> void:
	if not g_GameManager.is_manipulate():
		return
	if _gui_buy_card.targeting:
		_gui_buy_card.release_target()
		_button_card_remove.hide()
		_button_card.show()
		_gui_small_card.hide()
		_buying_card = false
	_button_round.hide()
	_button_card.hide()
	_reset_touch_state()
	g_Scene.unselect_area()
	_gui_tax.hide()
	_gui_sel_army.hide()
	g_Scene.camera.set_auto_fix_pos(false)
	g_Scene.flashing_turn_begin = false
	_set_auto_fix_position = false
	if g_GameManager.game_mode != 4:
		_gui_ai_progress.show()
		g_GameManager.end_turn()
		CActionAI.instance().init_ai()
		_update_ai_progress()
	else:
		g_GameManager.end_turn()
		# TODO: send multiplayer action


func _on_button_card_pressed() -> void:
	if not g_GameManager.is_manipulate():
		return
	_reset_touch_state()
	if _gui_buy_card.targeting:
		_gui_buy_card.release_target()
		_button_card_remove.hide()
		_button_card.show()
		_gui_small_card.hide()
		_buying_card = false
	_gui_buy_card.reset_card_state()
	_gui_buy_card.show()
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	g_SoundRes.play_char_se(SND_EFFECT.CARD_INTERFACE_WAV)


func _on_button_pause_pressed() -> void:
	_reset_touch_state()
	_gui_pause_box.show()


func _on_button_card_remove_pressed() -> void:
	_button_card_remove.hide()
	_button_card.show()
	_gui_small_card.hide()
	_gui_buy_card.release_target()


func _on_gui_pause_box_options_pressed() -> void:
	_gui_pause_box.hide()
	_gui_options = $GUIOptions.create_instance()
	_gui_options.closed.connect(_on_gui_options_closed)
	_gui_options.reparent(GUIManager.instance())


func _on_gui_pause_box_save_pressed() -> void:
	_gui_pause_box.hide()
	_gui_save = $GUISave.create_instance()
	_gui_save.game_mode = g_GameManager.game_mode
	_gui_save.loading = false
	_gui_save.back_pressed.connect(_on_gui_save_back_pressed)
	_gui_save.ok_pressed.connect(_on_gui_save_back_pressed)
	_gui_save.reparent(GUIManager.instance())


func _on_gui_pause_box_restart_pressed() -> void:
	g_GameManager.retry_game()
	GUIManager.instance().fade_out(14, null)


func _on_gui_pause_box_quit_pressed() -> void:
	if g_GameManager.game_mode == 4:
		# TODO: multiplayer
		pass
	else:
		GUIManager.instance().fade_out(9, null)


func _on_gui_buy_card_back_pressed() -> void:
	_gui_buy_card.hide()
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND


func _on_gui_buy_card_ok_pressed() -> void:
	if _gui_buy_card.get_sel_card() != null and _gui_buy_card.targeting:
		_button_card_remove.show()
		_button_card.hide()
		_gui_small_card.set_card(_gui_buy_card.get_sel_card())
		_gui_small_card.show()


func _on_gui_options_closed() -> void:
	_gui_options.queue_free()
	_gui_options = null
	_gui_pause_box.show()


func _on_gui_save_back_pressed() -> void:
	_gui_save.queue_free()
	_gui_save = null
	_gui_pause_box.show()


func _on_gui_attack_box_ok_pressed() -> void:
	_gui_attack_box.hide()
	var action := CountryAction.new()
	action.type = 3
	action.start_area = _gui_attack_box.attack
	action.army_index = 0
	action.target_area = _gui_attack_box.defend
	g_GameManager.get_cur_country().action(action)
	if g_GameManager.game_mode == 4:
		# TODO: send multiplayer action
		pass


func _on_gui_defeated_ok_pressed() -> void:
	_gui_defeated.hide_defeated()
	if not g_GameManager.check_and_set_result():
		return
	if g_GameManager.game_mode != 4:
		if g_GameManager.game_won:
			g_GameManager.battle_victory()
			var stars = g_GameManager.get_num_victory_stars()
			var dlg: String
			if stars <= 1 or g_GameManager.campaign_reward_medal > 0:
				dlg = "commander victory {0}".format([6 - stars])
			else:
				dlg = "commander victory {0} no award".format([6 - stars])
			show_dialogue(dlg, &"Guider", false)
		else:
			show_dialogue("commander failure 1", &"Guider", false)
	elif _gui_victory == null and g_GameManager.game_ended:
		_gui_victory = $GUIVictory.create_instance()
		_gui_victory.time_passed.connect(_on_gui_victory_time_passed)
		_gui_victory.victorious = g_GameManager.game_won
		_gui_victory.reparent(GUIManager.instance())
		_gui_victory.play()


func _on_gui_result_back_pressed() -> void:
	GUIManager.instance().fade_out(9, null)


func _on_gui_result_next_pressed() -> void:
	if g_GameManager.game_mode == 1:
		if g_GameManager.is_last_battle():
			GUIManager.instance().fade_out(20, null)
		else:
			g_GameManager.should_show_next_battle = true
			GUIManager.instance().fade_out(9, null)


func _on_gui_begin_ok_pressed() -> void:
	var dlg = g_GameManager.get_cur_dialogue()
	if dlg != null and dlg.at_round <= g_GameManager.current_round + 1:
		var s = g_GameManager.get_cur_dialogue_string()
		show_dialogue(s, dlg.commander, dlg.left)
		g_GameManager.next_dialogue()
	g_Scene.flashing_turn_begin = true


func _on_gui_begin_bank_pressed() -> void:
	_gui_bank = $GUIBank.create_instance()
	_gui_bank.reparent(GUIManager.instance())


func _on_gui_bank_back_pressed() -> void:
	if g_GameManager.game_mode == 4:
		# TODO: send multiplayer action
		pass
	_gui_bank.queue_free()
	_gui_bank = null
	_gui_begin.reset_data()


func _on_gui_end_back_pressed() -> void:
	GUIManager.instance().fade_out(9, null)


# TODO: receive signal from GUIWarning (multiplayer)
