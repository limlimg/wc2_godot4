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
	# NOTTODO: initialize CFightManager; seems unnecessary
	g_GameRes.load_res()
	#GUIManager.s_texture_res = load("res://scene_system_resource/game_gui_res/texture_res.tres").get_res()
	g_GameManager.init_battle()
	# NOTTODO: initialize CTouchInertia; not static var


func _on_enter() -> void:
	_button_round = $ButtonRound/Control/GUIButton.create_instance()
	_button_card = $ButtonCard/Control/GUIButton.create_instance()
	_button_pause = $ButtonPause/Control/GUIButton.create_instance()
	_button_card_remove = $ButtonCardRemove/GUIButton.create_instance()
	_gui_gold = $GUIGold.create_instance()
	_gui_tax = $GUITax.create_instance()
	_gui_small_card = $GUISmallCard.create_instance()
	_gui_attack_box = $GUIAttackBox.create_instance()
	_gui_pause_box = $GUIPauseBox.create_instance()
	_gui_buy_card = $GUIBuyCard/GUIBuyCard.create_instance()
	_gui_ai_progress = $GUIAIProgress/GUIAIProgress.create_instance()
	var cur_country := g_GameManager.get_cur_country()
	if cur_country != null and not cur_country.ai:
		_gui_ai_progress.hide()
	else:
		_update_ai_progress()
		if g_GameManager.game_mode == 4:
			_gui_ai_progress.hide()
	_gui_sel_army = $GUISelArmy.create_instance()
	_gui_begin = $GUIBegin.create_instance()
	if g_GameManager.game_mode == 4:
		_gui_action_info = $GUIActionInfo/GUIActionInfo.create_instance()
	_gui_defeated = $GUIDefeated.create_instance()
	_gui_battle = $GUIBattle.create_instance()
	if g_GameManager.game_mode == 5:
		_gui_tutorials = $GUITutorails.create_instance()
	else:
		_gui_dialogue = $GUIDialogue.create_instance()
	CSoundBox.get_instance().load_music("battle{0}.mp3".format([randi_range(1, 4)]), "")
	CSoundBox.get_instance().play_music(true)
	GUIManager.instance().fade_in(1)
	if g_GameManager.is_new_game and g_GameManager.game_mode != 4:
		g_GameManager.turn_begin()
	await GUIManager.instance().faded_in
	if g_GameManager.game_mode == 1:
		_gui_battle_intro = $GUIBattleIntro/GUIBattleIntro.create_instance()
		_gui_battle_intro.campaign = g_GameManager.campaign
		_gui_battle_intro.battle = g_GameManager.battle
		_gui_battle_intro.ok_pressed.connect(_on_gui_gui_battle_intro_ok_pressed)
	else:
		$AnimationPlayer.play(&"move_in")
	if g_GameManager.game_mode == 4:
		# TODO: send multiplayer data
		pass


func _update_ai_progress() -> void:
	var cur_country := g_GameManager.get_cur_country()
	if cur_country != null and not cur_country.ai:
		$GUIAIProgress/GUIAIProgress.set_cur_country_name(cur_country.name)
		$GUIAIProgress/GUIAIProgress.progress = CActionAI.instance().ai_progress_percentage


func _on_exit() -> void:
	_button_round.queue_free()
	_button_card.queue_free()
	_button_pause.queue_free()
	_button_card_remove.queue_free()
	_gui_gold.queue_free()
	_gui_tax.queue_free()
	_gui_small_card.queue_free()
	_gui_attack_box.queue_free()
	_gui_pause_box.queue_free()
	_gui_buy_card.queue_free()
	_gui_ai_progress.queue_free()
	_gui_sel_army.queue_free()
	_gui_begin.queue_free()
	if _gui_action_info != null:
		_gui_action_info.queue_free()
		_gui_action_info = null
	_gui_defeated.queue_free()
	_gui_battle.queue_free()
	if _gui_tutorials != null:
		_gui_tutorials.queue_free()
		_gui_tutorials = null
	if _gui_dialogue != null:
		_gui_dialogue.queue_free()
		_gui_dialogue = null
	if _gui_battle_intro != null:
		_gui_battle_intro.queue_free()
		_gui_battle_intro = null


func _on_gui_gui_battle_intro_ok_pressed() -> void:
	if g_GameManager.game_mode == 1:
		$AnimationPlayer.play(&"move_in")
		GUIManager.instance().safe_free_child(_gui_battle_intro)
		_gui_battle_intro = null


func _on_area_complained(complainer: StringName) -> void:
	show_dialogue("commander complain {0}".format([randi_range(1, 2)]), complainer, false)


func show_dialogue(dlg: String, general: StringName, left: bool) -> void:
	$GUIDialogue.show_dlg(dlg, general, left)
