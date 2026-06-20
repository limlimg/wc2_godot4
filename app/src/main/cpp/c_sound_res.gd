extends Node

const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")
const _SndEffect = preload("res://app/src/main/cpp/snd_effect.gd").SND_EFFECT

const _SND_FILE = [
	"draft.wav",
	"move.wav",
	"occupy.wav",
	"cannon.wav",
	"rocket.wav",
	"fire.wav",
	"exp.wav",
	"strike.wav",
	"select.wav",
	"cancel.wav",
	"ship.wav",
	"celebrate.wav",
	"after_war.wav",
	"buff.wav",
	"build.wav",
	"card_interface.wav",
	"gas.wav",
	"lvup.wav",
	"machine_gun.wav",
	"naval_gun.wav",
	"pop.wav",
	"supply.wav"
]

var _loaded := false

func load_res() -> void:
	if not _loaded:
		var sound := _CSoundBox.get_instance()
		for i in _SND_FILE:
			sound.load_se(i)
		sound.set_se_volume(g_GameSettings.se_volume)
		_loaded = true


func unload_res() -> void:
	var sound := _CSoundBox.get_instance()
	for i in _SND_FILE:
		sound.load_se(i)
	sound.set_se_volume(g_GameSettings.se_volume)
	_loaded = true


func play_char_se(se: _SndEffect) -> void:
	_CSoundBox.get_instance().play_se(_SND_FILE[se])
