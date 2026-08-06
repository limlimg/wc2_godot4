extends GUIElement

@export
var victorious: bool:
	set(value):
		if value != victorious:
			victorious = value
			init()


var _text: Control
var _play_time: float
var _playing: bool

signal time_passed

func init() -> void:
	if not is_node_ready():
		return
	super()
	_playing = false
	_play_time = -1.0
	if victorious:
		_text = $Victory.create_instance()
	else:
		_text = $GameOver.create_instance()


func play() -> void:
	$BoardEnd.scale.y = 0.2
	_playing = true
	_text.scale = Vector2(3.0, 3.0)
	_play_time = 0.0
	_text.self_modulate.a = 0.0
	if victorious:
		g_SoundRes.play_char_se(SND_EFFECT.CELEBRATE_WAV)
	else:
		CSoundBox.get_instance().unload_music()
		CSoundBox.get_instance().load_music("defeat_music.mp3", "")
		CSoundBox.get_instance().play_music(true)


func _process(delta: float) -> void:
	if _play_time < 0.0:
		return
	_play_time += delta
	if _play_time > 5.0:
		_play_time = -1.0
		time_passed.emit()
	if _playing:
		var text_scale := (_text.scale - Vector2(3.0, 3.0) * delta).max(Vector2.ONE)
		_text.scale = text_scale
		var a := minf(_text.self_modulate.a + 1.5 * delta, 1.0)
		_text.self_modulate.a = a
		if text_scale == Vector2.ONE:
			_playing = false
		var y := minf($BoardEnd.scale.y + 6.0 * delta, 1.0)
		$BoardEnd.scale.y = y
