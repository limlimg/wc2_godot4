extends CBaseState

var _loading: Control
var _loading_title: Control

func _on_enter() -> void:
	GUIManager.instance().event_receiver = $IEventReceiver
	GUIMotionManager.instance().event_receiver = $IEventReceiver
	_loading = $Loading.create_instance()
	_loading_title = $LoadingTitle.create_instance()
	$Tip/ecText.text = "tip {0}".format([randi_range(1, 11)])
	GUIManager.instance().fade_in(-1)


func _on_i_event_receiver_faded_in(_cause: int) -> void:
	CStateManager.instance().get_state_ptr(EState.GAME).init_game()
	GUIManager.instance().fade_out(-1, null)


func _on_i_event_receiver_faded_out(_cause: int) -> void:
	CStateManager.instance().set_cur_state(EState.GAME)


func _on_exit() -> void:
	_loading.queue_free()
	_loading_title.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released(&"ui_cancel"):
		get_viewport().set_input_as_handled()
