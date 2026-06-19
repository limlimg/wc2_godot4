extends "res://app/src/main/cpp/c_base_state.gd"

const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _CGameState = preload("res://app/src/main/cpp/c_game_state.gd")
const _CStateManager = preload("res://app/src/main/cpp/c_state_manager.gd")

static var _rng := RandomNumberGenerator.new()

var _load_thread := Thread.new()

signal _game_initialized

func _on_enter() -> void:
	var tip_index := _rng.randi_range(1, 11)
	$Tip/ecText.text = _native.g_string_table.get_string("tip {0}".format([tip_index]))
	$GUIManager.fade_in(-1)
	_load_thread.start(func():
		_CGameState.init_game()
		_game_initialized.emit())


func _on_gui_manager_faded_in(_cause: int) -> void:
	_game_initialized.connect(func():
		_load_thread.wait_to_finish()
		$GUIManager.fade_out(-1, null))
	if not _load_thread.is_alive():
		_game_initialized.emit()


func _on_gui_manager_faded_out(_cause: int) -> void:
	_CStateManager.instance().set_cur_state("res://app/src/main/cpp/c_game_state.tscn")
