extends "res://app/src/main/cpp/c_base_state.gd"

const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")
const _CActionAI = preload("res://app/src/main/cpp/c_action_ai.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")

var _battle_intro: Control

static func init_game() -> void:
	g_SoundRes.load_res()
	# NOTTODO: initialize CFightManager; seems unnecessary
	g_GameRes.load_res()
	#_GUIManager.s_texture_res = load("res://app/src/main/cpp/scene_system_resource/game_gui_res/texture_res.tres").get_res()
	g_GameManager.init_battle()
	# NOTTODO: initialize CTouchInertia; not static var


func _on_enter() -> void:
	var cur_country := g_GameManager.get_cur_country()
	if cur_country != null and not cur_country.ai:
		$GUIManager/GUIAIProgress.hide()
	else:
		_update_ai_progress()
		if g_GameManager.game_mode == 4:
			$GUIManager/GUIAIProgress.hide()
	if g_GameManager.game_mode == 4:
		$GUIManager/GUIActionInfo/GUIActionInfo.create_instance(true)
	if g_GameManager.game_mode == 5:
		$GUIManager/GUITutorails.create_instance(true)
	else:
		$GUIManager/GUIDialogue.create_instance(true)
	_CSoundBox.get_instance().load_music("battle{0}.mp3".format([randi_range(1, 4)]), "")
	_CSoundBox.get_instance().play_music(true)
	$GUIManager.fade_in(1)
	if g_GameManager.is_new_game and g_GameManager.game_mode != 4:
		g_GameManager.turn_begin()
	await $GUIManager.faded_in
	if g_GameManager.game_mode == 1:
		_battle_intro = $GUIManager/GUIBattleIntro/GUIBattleIntro.create_instance()
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
		$GUIManager/GUIAIProgress/GUIAIProgress.set_cur_country_name(cur_country.name)
		$GUIManager/GUIAIProgress/GUIAIProgress.progress = _CActionAI.instance().ai_progress_percentage


func _on_gui_battle_intro_ok_pressed() -> void:
	if g_GameManager.game_mode == 1:
		$AnimationPlayer.play(&"move_in")
		$GUIManager.safe_free_child(_battle_intro)
		_battle_intro = null


func _on_area_complained(complainer: StringName) -> void:
	show_dialogue("commander complain {0}".format([randi_range(1, 2)]), complainer, false)


func show_dialogue(dlg: String, general: StringName, left: bool) -> void:
	$GUIManager/GUIDialogue.show_dlg(dlg, general, left)
