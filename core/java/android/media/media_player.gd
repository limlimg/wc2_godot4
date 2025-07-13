extends Node

## For the Android MediaPlayer class, it is possible to set different left and
## right volumes. This feature is not used in the original game code and not
## implemented in this project.

const _MediaPlayer = preload("res://core/java/android/media/media_player.gd")

var _player_node: AudioStreamPlayer
var _data_source := ""
var _loading := false
var _looping: bool

signal _prepared(mp: _MediaPlayer)

func _init() -> void:
	_player_node = AudioStreamPlayer.new()
	add_child(_player_node)


func release() -> void:
	if _player_node != null:
		remove_child(_player_node)
		_player_node.queue_free()
		_player_node = null
	if _loading:
		ResourceLoader.load_threaded_get(_data_source)
	for connection in _prepared.get_connections():
		_prepared.disconnect(connection["callable"])


func set_data_source(data_source: String) -> void:
	if _loading:
		return
	_data_source = data_source


func set_on_prepared_listener(listener: Callable) -> void:
	if _player_node == null or _player_node.stream != null:
		return
	_prepared.connect(listener)


func prepare_async() -> void:
	if _player_node == null or _data_source == "" or _loading or _player_node.stream != null:
		return
	var err := ResourceLoader.load_threaded_request(_data_source)
	if err != OK:
		push_error("{0}: Failed to load {1}".format([error_string(err), _data_source]))
		return
	_loading = true


func set_looping(looping: bool) -> void:
	_looping = looping
	if _player_node == null or _player_node.stream == null:
		return
	_player_node.stream.loop = looping


func seek_to(msec: int) -> void:
	if _player_node == null:
		return
	_player_node.seek(0.001 * msec)


func start() -> void:
	if _player_node == null:
		return
	if not _player_node.playing:
		_player_node.play()
	_player_node.stream_paused = false


func pause() -> void:
	if _player_node == null:
		return
	_player_node.stream_paused = true


func stop() -> void:
	if _player_node == null:
		return
	_player_node.stop()


func is_playing() -> bool:
	if _player_node == null:
		return false
	return _player_node.playing and not _player_node.stream_paused


func set_volume (left_volume: float, right_volume: float) -> void:
	if _player_node == null:
		return
	_player_node.volume_linear = (left_volume + right_volume) / 2.0


func _process(_delta: float) -> void:
	if _loading:
		var stat := ResourceLoader.load_threaded_get_status(_data_source)
		if stat != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if stat == ResourceLoader.THREAD_LOAD_LOADED:
				if _player_node != null:
					var stream := ResourceLoader.load_threaded_get(_data_source)
					var loop_stream := AudioStreamPlaylist.new()
					loop_stream.fade_time = 0.0
					loop_stream.loop = _looping
					loop_stream.stream_count = 1
					loop_stream.set_list_stream(0, stream)
					_player_node.stream = loop_stream
					_prepared.emit(self)
			_loading = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		release()
