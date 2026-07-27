class_name CSoundBox
extends Node

static var _m_instance: CSoundBox

var _music: AudioStreamPlayer
var _loading_music_path: String
var _play_music_on_load: bool
var _se: AudioStreamPlayer
var _loaded_se: Dictionary[String, AudioStream]
var _play_se_on_load: Dictionary[String, bool]

static func get_instance() -> CSoundBox:
	if _m_instance == null:
		_m_instance = (Engine.get_main_loop() as SceneTree).get_first_node_in_group(&"_ZN10CCSoundBox9mInstanceE")
		_m_instance._init_sound_system()
	return _m_instance


func _init_sound_system() -> void:
	_music = AudioStreamPlayer.new()
	_music.stream = AudioStreamPlaylist.new()
	_music.stream.fade_time = 0.0
	_se = AudioStreamPlayer.new()
	_se.stream = AudioStreamPolyphonic.new()
	var root := (Engine.get_main_loop() as SceneTree).root
	if not root.is_node_ready():
		await root.ready
	root.add_child(_music)
	root.add_child(_se)


static func destroy() -> void:
	if _m_instance != null:
		_m_instance._destroy_sound_system()
		_m_instance = null


func _destroy_sound_system() -> void:
	if not _loading_music_path.is_empty():
		ResourceLoader.load_threaded_get(_loading_music_path)
	for k in _play_se_on_load.keys():
		ResourceLoader.load_threaded_get(k)
	_music.queue_free()
	_se.queue_free()


func load_music(music_name: String, extension: String) -> void:
	if not _loading_music_path.is_empty():
		ResourceLoader.load_threaded_get(_loading_music_path)
	_play_music_on_load = false
	_music.stream.stream_count = 0
	_loading_music_path = EC2dAppDelegate.get_asset_path(music_name, extension)
	if _loading_music_path.is_empty():
		return
	ResourceLoader.load_threaded_request(_loading_music_path)


func unload_music() -> void:
	if not _loading_music_path.is_empty():
		ResourceLoader.load_threaded_get(_loading_music_path)
	_loading_music_path = ""
	_music.stream.stream_count = 0


func play_music(looping: bool) -> void:
	_music.stream.loop = looping
	if _music.stream.stream_count == 0:
		if not _loading_music_path.is_empty():
			_play_music_on_load = true
	else:
		_music.play()


func stop_music() -> void:
	_music.stop()


func set_music_volume(volume: int) -> void:
	_music.volume_linear = (volume / 100.0)


func load_se(se_name: String) -> void:
	var path = EC2dAppDelegate.get_asset_path(se_name, "")
	if path.is_empty():
		return
	_play_se_on_load[path] = false
	ResourceLoader.load_threaded_request(path)


func unload_se(se_name: String) -> void:
	var path = EC2dAppDelegate.get_asset_path(se_name, "")
	if _play_se_on_load.has(path):
		ResourceLoader.load_threaded_get(path)
		_play_se_on_load.erase(path)
	if _loaded_se.has(path):
		_loaded_se.erase(path)


func play_se(se_name: String) -> int:
	var path = EC2dAppDelegate.get_asset_path(se_name, "")
	if _loaded_se.has(path):
		if not _se.playing:
			_se.play()
		return _se.get_stream_playback().play_stream(_loaded_se[path])
	else:
		_play_se_on_load[path] = true
		ResourceLoader.load_threaded_request(path)
		return -1


func _stop_all_se() -> void:
	_se.stop()


func set_se_volume(volume: int) -> void:
	_se.volume_linear = volume / 100.0


func _process(_delta: float) -> void:
	if not _loading_music_path.is_empty():
		var status := ResourceLoader.load_threaded_get_status(_loading_music_path)
		if status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				_music.stream.stream_count = 1
				_music.stream.set_list_stream(0, ResourceLoader.load_threaded_get(_loading_music_path))
				if _play_music_on_load:
					_music.play()
			_loading_music_path = ""
	for k in _play_se_on_load.keys():
		var status := ResourceLoader.load_threaded_get_status(k)
		if status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				_loaded_se[k] = ResourceLoader.load_threaded_get(k)
				if _play_se_on_load[k]:
					if not _se.playing:
						_se.play()
					_se.get_stream_playback().play_stream(_loaded_se[k])
			_play_se_on_load.erase(k)
	update_sound()


func update_sound() -> void:
	# empty in both original ios and android code, why?
	pass
