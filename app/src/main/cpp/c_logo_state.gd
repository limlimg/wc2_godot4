extends Control

class _CLogoState:
	extends "res://app/src/main/cpp/native-lib.gd"
	
	static func on_enter() -> void:
		g_game_settings.load_settings()
		var sound_box := _CSoundBox.get_instance()
		sound_box.set_music_volume(g_game_settings.music_volume)
		sound_box.set_se_volume(g_game_settings.se_volume)
		# NOTTODO: load textureres for uis. Handled by ecTextureResAssets


func _ready() -> void:
	_CLogoState.on_enter()
	var tween := create_tween()
	tween.tween_interval(2.1)
	tween.tween_callback(func ():
		$GUIManager.fade_out(-1, null))
	$GUIManager.faded_out.connect(func (_cause: int):
		var tween2 := create_tween()
		tween2.tween_interval(1.0)
		# TODO: initialize player manager
		# TODO: change to menu state
		)
