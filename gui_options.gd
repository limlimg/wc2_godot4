extends GUIElement

signal closed

func _ready() -> void:
	init()


func init() -> void:
	$Music/GUIScrollBar.set_scroll_pos(g_GameSettings.music_volume)
	$SFX/GUIScrollBar.set_scroll_pos(g_GameSettings.se_volume)
	$AnimationButton/GUIButton.visible = not g_GameSettings.battle_animation
	$AnimationCheck/GUIButtonEx.visible = g_GameSettings.battle_animation
	$Speed/GUILevelSel.value = g_GameSettings.speed


func _on_gui_button_back_pressed() -> void:
	closed.emit()


func _on_gui_button_ok_pressed() -> void:
	var sound := CSoundBox.get_instance()
	var music = $Music/GUIScrollBar.get_scroll_pos()
	sound.set_music_volume(music)
	g_GameSettings.music_volume = music
	var se = $SFX/GUIScrollBar.get_scroll_pos()
	sound.set_se_volume(se)
	g_GameSettings.se_volume = se
	g_GameSettings.battle_animation = $AnimationCheck/GUIButtonEx.visible
	g_GameSettings.speed = $Speed/GUILevelSel.value
	g_GameSettings.save_settings()
	closed.emit()


func _set_animation(value: bool) -> void:
	$AnimationButton/GUIButton.visible = not value
	$AnimationCheck/GUIButtonEx.visible = value
