extends GUIElement

@export
var victorious: bool

signal time_passed

func play() -> void:
	if victorious:
		g_SoundRes.play_char_se(SND_EFFECT.CELEBRATE_WAV)
		$AnimationPlayer.play(&"victory")
	else:
		CSoundBox.get_instance().unload_music()
		CSoundBox.get_instance().load_music("defeat_music.mp3", "")
		CSoundBox.get_instance().play_music(true)
		$AnimationPlayer.play(&"defeat")
	var tween := create_tween()
	tween.tween_interval(5.0)
	tween.tween_callback(time_passed.emit)
