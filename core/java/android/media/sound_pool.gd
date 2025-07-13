extends Node

## For the Android SoundPool class, it is possible to set different left and
## right volumes and to pause or resume each stream. These features are not
## implemented in this project as they are not supported by AudioStreamPolyphonic.

const _SoundPool = preload("res://core/java/android/media/sound_pool.gd")

class _Promise:
	var _fulfilled: bool
	var _result: int
	
	signal _settled

var _player_node: AudioStreamPlayer
var _sound_path: Array[String]
var _sound_res: Array[AudioStream]
var _loading_id: Array[int]
var _playing_stream_queue: PackedInt64Array
var _stopping_stream_count := 0
var _waiting_queue: Array[_Promise]

signal _load_complete(sound_pool: _SoundPool, sample_id: int, status: Error)

func _init(max_streams: int) -> void:
	_player_node = AudioStreamPlayer.new()
	add_child(_player_node)
	_player_node.stream = AudioStreamPolyphonic.new()
	_player_node.stream.polyphony = max_streams


func release() -> void:
	if _player_node != null:
		remove_child(_player_node)
		_player_node.queue_free()
		_player_node = null
	_sound_path.clear()
	_sound_res.clear()
	for id in _loading_id:
		ResourceLoader.load_threaded_get(_sound_path[id])
	for connection in _load_complete.get_connections():
		_load_complete.disconnect(connection["callable"])


func set_on_load_complete_listener(listener: Callable) -> void:
	if _player_node == null:
		return
	_load_complete.connect(listener)


func load(path: String) -> int:
	if _player_node == null:
		return -1
	var id:= _sound_path.find(path)
	if id != -1:
		return id
	var err := ResourceLoader.load_threaded_request(path)
	if err != OK:
		push_error("Failed to load {}: {}".format([path, error_string(err)]))
		return -1
	var new_sound_id := _sound_path.find("")
	if new_sound_id == -1:
		new_sound_id = _sound_path.size()
		_sound_path.append(path)
		_sound_res.append(null)
	else:
		_sound_path[new_sound_id] = path
	_loading_id.append(new_sound_id)
	return new_sound_id


## This method cannot be used to cancle the loading.
func unload(sound_id: int) -> bool:
	if _sound_path.size() <= sound_id or _sound_res[sound_id] == null:
		return false
	_sound_path[sound_id] = ""
	_sound_res[sound_id] = null
	return true


## This function has no effect if the sound hasn't actually been loaded. This
## behaviour is consistent with the Android class.
func play(sound_id: int, left_volume: float, right_volume: float, loop: int) -> int:
	if _player_node == null:
		return -1
	var stream := _sound_res[sound_id]
	if stream == null:
		return -1
	if not _player_node.playing:
		_player_node.play()
	var playback: AudioStreamPlaybackPolyphonic = _player_node.get_stream_playback()
	var position = _update_stream_queue(playback, 1)
	# Now _playing_stream_queue has j valid entries.
	if position >= _player_node.stream.polyphony:
		playback.stop_stream(_playing_stream_queue[_stopping_stream_count]) # Somehow, this method stops the stream asynchronously
		_stopping_stream_count += 1
		var promise := _Promise.new()
		_waiting_queue.append(promise)
		await promise._settled
		if not promise._fulfilled:
			return -1
		position = promise._result
	if loop == -1:
		var loop_stream := AudioStreamPlaylist.new()
		loop_stream.fade_time = 0.0
		loop_stream.loop = true
		loop_stream.stream_count = 1
		loop_stream.set_list_stream(0, stream)
		stream = loop_stream
	var new_stream_id := playback.play_stream(stream, 0.0, linear_to_db((left_volume + right_volume)/2.0))
	if new_stream_id != -1:
		_playing_stream_queue[position] = new_stream_id
	return new_stream_id


func _update_stream_queue(playback: AudioStreamPlaybackPolyphonic, alloc: int) -> int:
	var i := 0
	var j := 0
	var stopping_complete_count := 0
	while i < _playing_stream_queue.size():
		if playback.is_stream_playing(_playing_stream_queue[i]):
			if j != i:
				_playing_stream_queue[j] = _playing_stream_queue[i]
			j += 1
		elif i < _stopping_stream_count:
			stopping_complete_count += 1
		i += 1
	# Now _playing_stream_queue has j valid entries.
	_stopping_stream_count -= stopping_complete_count
	if _waiting_queue.size() == _player_node.stream.polyphony:
		var promise: _Promise = _waiting_queue.pop_front()
		promise._fulfilled = false
		promise._settled.emit()
	_playing_stream_queue.resize(min(j + _waiting_queue.size() + alloc, _player_node.stream.polyphony))
	while j < _player_node.stream.polyphony and _waiting_queue.size() > 0:
		var promise: _Promise = _waiting_queue.pop_front()
		promise._fulfilled = true
		promise._result = j
		promise._settled.emit()
		j += 1
	return j


func auto_pause() -> void:
	if _player_node == null:
		return
	_player_node.stream_paused = true


func auto_resume() -> void:
	if _player_node == null:
		return
	_player_node.stream_paused = false


func stop(stream_id: int) -> void:
	if _player_node == null or not _player_node.playing:
		return
	var playback: AudioStreamPlaybackPolyphonic = _player_node.get_stream_playback()
	playback.stop_stream(stream_id)


func set_volume(stream_id: int, left_volume: float, right_volume: float) -> void:
	if _player_node == null or not _player_node.playing:
		return
	var playback: AudioStreamPlaybackPolyphonic = _player_node.get_stream_playback()
	playback.set_stream_volume(stream_id, linear_to_db((left_volume + right_volume)/2.0))


func _process(_delta: float) -> void:
	if _player_node != null and _player_node.playing and not _waiting_queue.is_empty():
		_update_stream_queue(_player_node.get_stream_playback(), 0)
	var i := 0
	while i < _loading_id.size():
		var id := _loading_id[i]
		var stat := ResourceLoader.load_threaded_get_status(_sound_path[id])
		if stat != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var success := stat == ResourceLoader.THREAD_LOAD_LOADED
			if success:
				_sound_res[id] = ResourceLoader.load_threaded_get(_sound_path[id])
			_load_complete.emit(self, id, OK if success else FAILED)
			if not success:
				push_error("Failed to load {0}".format([_sound_path[id]]))
				_sound_path[id] = ""
			_loading_id[i] = _loading_id.back()
			_loading_id.pop_back()
		else:
			i += 1


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		release()
