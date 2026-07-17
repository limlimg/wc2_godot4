extends CBaseState

func _on_enter() -> void:
	$Tip/Label.text = "tip {0}".format([randi_range(1, 11)])
	GUIManager.instance().fade_in(-1)
	await GUIManager.instance().faded_in
	CGameState.init_game()
	GUIManager.instance().fade_out(-1, null)
	await GUIManager.instance().faded_out
	CStateManager.instance().set_cur_state(EState.GAME)
