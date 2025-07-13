extends Node

## Part of the original code handles subtitles. They are unused in the original
## code and not ported.

const _MediaPlayer = preload("res://core/java/android/media/media_player.gd")

var _m_background_media_player: _MediaPlayer
var _m_current_path: String
var _m_is_paused: bool
var _m_manual_paused := false
var _m_left_volume: float
var _m_right_volume: float

func _init() -> void:
	_init_data()


func end() -> void:
	if _m_background_media_player != null:
		_m_background_media_player.release()
		remove_child(_m_background_media_player)
		_m_background_media_player.queue_free()
	_init_data()


func _init_data() -> void:
	_m_left_volume = 0.5
	_m_right_volume = 0.5
	_m_background_media_player = null
	_m_is_paused = false
	_m_current_path = ""


func preload_background_music(path: String) -> void:
	if _m_current_path != path:
		if _m_background_media_player != null:
			_m_background_media_player.release()
			remove_child(_m_background_media_player)
			_m_background_media_player.queue_free()
		_m_background_media_player = _create_media_player_from_assets(path)
		add_child(_m_background_media_player)
		_m_current_path = path


func _create_media_player_from_assets(path: String) -> _MediaPlayer:
	var player := _MediaPlayer.new()
	player.set_data_source(path)
	player.set_volume(_m_left_volume, _m_right_volume)
	return player


func play_background_music(looping: bool) -> void:
	if _m_background_media_player == null:
		push_error("playBackgroundMusic: background media player is null")
		return
	_m_background_media_player.set_looping(looping)
	_m_background_media_player.set_on_prepared_listener(func (_mp: _MediaPlayer):
		_m_background_media_player.seek_to(0)
		_m_background_media_player.start()
	)
	_m_background_media_player.prepare_async()
	_m_is_paused = false


func pause_background_music() -> void:
	if _m_background_media_player == null or not _m_background_media_player.is_playing():
		return
	_m_background_media_player.pause()
	_m_is_paused = true


func resume_background_music() -> void:
	if _m_background_media_player == null or not _m_is_paused:
		return
	_m_background_media_player.start()
	_m_is_paused = false


func stop_background_music() -> void:
	if _m_background_media_player == null:
		return
	_m_background_media_player.stop()
	_m_is_paused = false


func get_background_volume() -> float:
	if _m_background_media_player == null:
		return 0.0
	return (_m_left_volume + _m_right_volume) / 2.0


func set_background_volume(volume: float) -> void:
	volume = clampf(volume, 0.0, 1.0)
	_m_left_volume = volume
	_m_right_volume = volume
	if _m_background_media_player != null:
		_m_background_media_player.set_volume(volume, volume)


# Despite its name, this function is never called in the original game code or here. (You can also notice that there is no _on_enter_background.)
func _on_enter_foreground() -> void:
	if not _m_manual_paused and _m_background_media_player != null and _m_is_paused:
		_m_background_media_player.start()
		_m_is_paused = false
