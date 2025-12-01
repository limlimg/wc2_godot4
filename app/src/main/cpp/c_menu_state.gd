extends Control

class _CMenuState:
	extends "res://app/src/main/cpp/native-lib.gd"
	
	static func on_enter() -> void:
		var sound_box := _CSoundBox.get_instance()
		sound_box.load_music("battle1.mp3", "")
		sound_box.play_music(true)


func _ready() -> void:
	_CMenuState.on_enter()


func _on_gui_manager_faded_in(_cause: int) -> void:
	$GUIManager/GUIMainMenu.move_in_main_buttons()
