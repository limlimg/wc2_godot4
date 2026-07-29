class_name CGameState
extends CBaseState

var _button_round: Control
var _button_card: Control
var _button_pause: Control
var _button_card_remove: Control
var _gui_gold: Control
var _gui_tax: Control
var _gui_small_card: Control
var _gui_attack_box: Control
var _gui_pause_box: Control
var _gui_buy_card: Control
var _gui_ai_progress: Control
var _gui_sel_army: Control
var _gui_begin: Control
var _gui_action_info: Control
var _gui_defeated: Control
var _gui_battle: Control
var _gui_tutorials: Control
var _gui_dialogue: Control
var _gui_battle_intro: Control

static func init_game() -> void:
	g_SoundRes.load_res()
	g_FightTextMgr.init()
	g_GameRes.load_res()
	if EC2dAppDelegate.g_content_scale_factor == 2.0:
		GUIManager.instance().load_texture_res("cardtex_hd.xml", true)
	else:
		GUIManager.instance().load_texture_res("cardtex.xml", false)
	g_GameManager.init_battle()
	# NOTTODO: initialize CTouchInertia; not static var


func _on_enter() -> void:
	var gui_manager := GUIManager.instance()
	_button_round = $ButtonRound.create_instance()
	_button_round.reparent(gui_manager)
	_button_card = $ButtonCard.create_instance()
	_button_card.reparent(gui_manager)
	_button_pause = $ButtonPause.create_instance()
	_button_pause.reparent(gui_manager)
	_button_card_remove = $ButtonCardRemove.create_instance()
	_button_card_remove.reparent(gui_manager)
	_gui_gold = $GUIGold.create_instance()
	_gui_gold.reparent(gui_manager)
	_gui_tax = $GUITax.create_instance()
	_gui_tax.reparent(gui_manager)
	_gui_small_card = $GUISmallCard.create_instance()
	_gui_small_card.reparent(gui_manager)
	_gui_attack_box = $GUIAttackBox.create_instance()
	_gui_attack_box.reparent(gui_manager)
	_gui_pause_box = $GUIPauseBox.create_instance()
	_gui_pause_box.reparent(gui_manager)
	_gui_buy_card = $GUIBuyCard.create_instance()
	_gui_buy_card.reparent(gui_manager)
	_gui_ai_progress = $GUIAIProgress.create_instance()
	_gui_ai_progress.reparent(gui_manager)
	var cur_country = g_GameManager.get_cur_country()
	if cur_country != null and not cur_country.ai:
		_gui_ai_progress.hide()
	else:
		_update_ai_progress()
		if g_GameManager.game_mode == 4:
			_gui_ai_progress.hide()
	_gui_sel_army = $GUISelArmy.create_instance()
	_gui_sel_army.reparent(gui_manager)
	_gui_begin = $GUIBegin.create_instance()
	_gui_begin.reparent(gui_manager)
	if g_GameManager.game_mode == 4:
		_gui_action_info = $GUIActionInfo.create_instance()
		_gui_action_info.reparent(gui_manager)
	_gui_defeated = $GUIDefeated.create_instance()
	_gui_defeated.reparent(gui_manager)
	_gui_battle = $GUIBattle.create_instance()
	_gui_battle.reparent(gui_manager)
	if g_GameManager.game_mode == 5:
		_gui_tutorials = $GUITutorails.create_instance()
		_gui_tutorials.reparent(gui_manager)
	else:
		_gui_dialogue = $GUIDialogue.create_instance()
		_gui_dialogue.reparent(gui_manager)
	var motion := GUIMotionManager.instance()
	var target := _button_round.position - _button_round.size
	var motion1 := motion.add_motion_from_current_position(_button_round, target.x, target.y, 3.0, 0)
	target = _button_card.position - _button_card.size
	var motion2 := motion.add_motion_from_current_position(_button_card, 0.0, target.y, 3.0, 0)
	target = _button_pause.position - _button_pause.size
	var motion3 := motion.add_motion_from_current_position(_button_pause, target.x, 0.0, 3.0, 0)
	var motion4 := motion.add_motion_from_current_position(_gui_gold, 0.0, 0.0, 3.0, 0)
	CSoundBox.get_instance().load_music("battle{0}.mp3".format([randi_range(1, 4)]), "")
	CSoundBox.get_instance().play_music(true)
	GUIManager.instance().fade_in(1)
	if g_GameManager.is_new_game and g_GameManager.game_mode != 4:
		g_GameManager.turn_begin()
	await GUIManager.instance().faded_in
	if g_GameManager.game_mode == 1:
		_gui_battle_intro = $GUIBattleIntro.create_instance()
		_gui_battle_intro.reparent(gui_manager)
		_gui_battle_intro.campaign = g_GameManager.campaign
		_gui_battle_intro.battle = g_GameManager.battle
		_gui_battle_intro.ok_pressed.connect(_on_gui_gui_battle_intro_ok_pressed)
	else:
		motion.active_motion(motion1, 0)
		motion.active_motion(motion2, 0)
		motion.active_motion(motion3, 0)
		motion.active_motion(motion4, 0)
	if g_GameManager.game_mode == 4:
		# TODO: send multiplayer data
		pass


func _update_ai_progress() -> void:
	var cur_country = g_GameManager.get_cur_country()
	if cur_country != null and not cur_country.ai:
		_gui_ai_progress.set_cur_country_name(cur_country.name)
		_gui_ai_progress.progress = CActionAI.instance().ai_progress_percentage


func _on_exit() -> void:
	GUIMotionManager.instance().clear_motion()
	GUIManager.instance().free_all_child()


func _on_gui_gui_battle_intro_ok_pressed() -> void:
	if g_GameManager.game_mode == 1:
		$AnimationPlayer.play(&"move_in")
		GUIManager.instance().safe_free_child(_gui_battle_intro)
		_gui_battle_intro = null


func _on_area_complained(complainer: StringName) -> void:
	show_dialogue("commander complain {0}".format([randi_range(1, 2)]), complainer, false)


func show_dialogue(dlg: String, general: StringName, left: bool) -> void:
	_gui_dialogue.show_dlg(dlg, general, left)
