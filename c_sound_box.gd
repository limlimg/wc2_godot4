class_name CSoundBox
extends Node

var _loading_music_path: String
var _play_music_on_load: bool
var _loaded_se: Dictionary[String, AudioStream]
var _play_se_on_load: Dictionary[String, bool]

static func get_instance() -> CSoundBox:
	return CSoundBoxInstance


func _init_sound_system() -> void:
	# nothing to do
	pass


static func destroy() -> void:
	CSoundBoxInstance._destroy_sound_system()


func _destroy_sound_system() -> void:
	if not _loading_music_path.is_empty():
		ResourceLoader.load_threaded_get(_loading_music_path)
	for k in _play_se_on_load.keys():
		ResourceLoader.load_threaded_get(k)
	$Music.stream.stream_count = 0
	_loaded_se.clear()


func update_sound() -> void:
	# nothing to do
	pass


func load_music(music_name: String, extension: String) -> void:
	if not _loading_music_path.is_empty():
		ResourceLoader.load_threaded_get(_loading_music_path)
	_play_music_on_load = false
	$Music.stream.stream_count = 0
	_loading_music_path = AppDelegate.get_asset_path(music_name, extension)
	if _loading_music_path.is_empty():
		return
	ResourceLoader.load_threaded_request(_loading_music_path)


func unload_music() -> void:
	if not _loading_music_path.is_empty():
		ResourceLoader.load_threaded_get(_loading_music_path)
	_loading_music_path = ""
	$Music.stream.stream_count = 0


func play_music(looping: bool) -> void:
	$Music.stream.loop = looping
	if $Music.stream.stream_count == 0:
		if not _loading_music_path.is_empty():
			_play_music_on_load = true
	else:
		$Music.play()


func stop_music() -> void:
	$Music.stop()


func set_music_volume(volume: int) -> void:
	$Music.volume_linear = (volume / 100.0)


func load_se(se_name: String) -> void:
	var path = AppDelegate.get_asset_path(se_name, "")
	if path.is_empty():
		return
	_play_se_on_load[path] = false
	ResourceLoader.load_threaded_request(path)


func unload_se(se_name: String) -> void:
	var path = AppDelegate.get_asset_path(se_name, "")
	if _play_se_on_load.has(path):
		ResourceLoader.load_threaded_get(path)
		_play_se_on_load.erase(path)
	if _loaded_se.has(path):
		_loaded_se.erase(path)


func play_se(se_name: String) -> int:
	var path = AppDelegate.get_asset_path(se_name, "")
	if _loaded_se.has(path):
		if not $SE.playing:
			$SE.play()
		return $SE.get_stream_playback().play_stream(_loaded_se[path])
	else:
		_play_se_on_load[path] = true
		ResourceLoader.load_threaded_request(path)
		return -1


func _stop_all_se() -> void:
	$SE.stop()


func set_se_volume(volume: int) -> void:
	$SE.volume_linear = volume / 100.0


func _process(_delta: float) -> void:
	if not _loading_music_path.is_empty():
		var status := ResourceLoader.load_threaded_get_status(_loading_music_path)
		if status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				$Music.stream.stream_count = 1
				$Music.stream.set_list_stream(0, ResourceLoader.load_threaded_get(_loading_music_path))
				if _play_music_on_load:
					$Music.play()
			_loading_music_path = ""
	for k in _play_se_on_load.keys():
		var status := ResourceLoader.load_threaded_get_status(k)
		if status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				_loaded_se[k] = ResourceLoader.load_threaded_get(k)
				if _play_se_on_load[k]:
					if not $SE.playing:
						$SE.play()
					$SE.get_stream_playback().play_stream(_loaded_se[k])
			_play_se_on_load.erase(k)
	update_sound()
