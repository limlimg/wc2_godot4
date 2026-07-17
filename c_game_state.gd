class_name CGameState
extends CBaseState

var _battle_intro: Control

static func init_game() -> void:
	g_SoundRes.load_res()
	# NOTTODO: initialize CFightManager; seems unnecessary
	g_GameRes.load_res()
	#GUIManager.s_texture_res = load("res://scene_system_resource/game_gui_res/texture_res.tres").get_res()
	g_GameManager.init_battle()
	# NOTTODO: initialize CTouchInertia; not static var


func _on_enter() -> void:
	var cur_country := g_GameManager.get_cur_country()
	if cur_country != null and not cur_country.ai:
		$GUIAIProgress.hide()
	else:
		_update_ai_progress()
		if g_GameManager.game_mode == 4:
			$GUIAIProgress.hide()
	if g_GameManager.game_mode == 4:
		$GUIActionInfo/GUIActionInfo.create_instance(true)
	if g_GameManager.game_mode == 5:
		$GUITutorails.create_instance(true)
	else:
		$GUIDialogue.create_instance(true)
	CSoundBox.get_instance().load_music("battle{0}.mp3".format([randi_range(1, 4)]), "")
	CSoundBox.get_instance().play_music(true)
	GUIManager.instance().fade_in(1)
	if g_GameManager.is_new_game and g_GameManager.game_mode != 4:
		g_GameManager.turn_begin()
	await GUIManager.instance().faded_in
	if g_GameManager.game_mode == 1:
		_battle_intro = $GUIBattleIntro/GUIBattleIntro.create_instance()
		_battle_intro.campaign = g_GameManager.campaign
		_battle_intro.battle = g_GameManager.battle
		_battle_intro.ok_pressed.connect(_on_gui_battle_intro_ok_pressed)
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


func _on_gui_battle_intro_ok_pressed() -> void:
	if g_GameManager.game_mode == 1:
		$AnimationPlayer.play(&"move_in")
		GUIManager.instance().safe_free_child(_battle_intro)
		_battle_intro = null


func _on_area_complained(complainer: StringName) -> void:
	show_dialogue("commander complain {0}".format([randi_range(1, 2)]), complainer, false)


func show_dialogue(dlg: String, general: StringName, left: bool) -> void:
	$GUIDialogue.show_dlg(dlg, general, left)
