extends "res://app/src/main/cpp/gui_element.gd"

const _SndEffect = preload("res://app/src/main/cpp/snd_effect.gd").SND_EFFECT
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")

@export
var victorious: bool

signal time_passed

func play() -> void:
	if victorious:
		g_SoundRes.play_char_se(_SndEffect.CELEBRATE_WAV)
		$AnimationPlayer.play(&"victory")
	else:
		_CSoundBox.get_instance().unload_music()
		_CSoundBox.get_instance().load_music("defeat_music.mp3", "")
		_CSoundBox.get_instance().play_music(true)
		$AnimationPlayer.play(&"defeat")
	var tween := create_tween()
	tween.tween_interval(5.0)
	tween.tween_callback(time_passed.emit)
