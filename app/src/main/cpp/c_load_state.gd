extends "res://app/src/main/cpp/c_base_state.gd"

const _CGameState = preload("res://app/src/main/cpp/c_game_state.gd")
const _CStateManager = preload("res://app/src/main/cpp/c_state_manager.gd")

func _on_enter() -> void:
	$Tip/Label.text = "tip {0}".format([randi_range(1, 11)])
	$GUIManager.fade_in(-1)
	await $GUIManager.faded_in
	_CGameState.init_game()
	$GUIManager.fade_out(-1, null)
	await $GUIManager.faded_out
	_CStateManager.instance().set_cur_state("res://app/src/main/cpp/c_game_state.tscn")
