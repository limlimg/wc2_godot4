extends CBaseState

var _loading: Control
var _loading_title: Control

func _on_enter() -> void:
	GUIManager.instance().event_receiver = $IEventReceiver
	_loading = $Loading.create_instance()
	_loading_title = $LoadingTitle.create_instance()
	$Tip/ecText.text = "tip {0}".format([randi_range(1, 11)])
	GUIManager.instance().fade_in(-1)


func _on_i_event_receiver_faded_in(_cause: int) -> void:
	CGameState.init_game()
	GUIManager.instance().fade_out(-1, null)


func _on_i_event_receiver_faded_out(cause: int) -> void:
	CStateManager.instance().set_cur_state(EState.GAME)


func _on_exit() -> void:
	_loading.queue_free()
	_loading_title.queue_free()
