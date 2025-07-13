extends Node

## Following SoundPool, it is not possible to pause or resume individual streams
## while it is in the original code.

const _SoundPool = preload("res://core/java/android/media/sound_pool.gd")

class _SoundInfoForLoadedCompleted:
	var _effect_id: int
	var _is_loop: bool
	var _path: String
	
	signal _played_when_loaded
	
	func _init(path: String, is_loop: bool) -> void:
		_path = path
		_is_loop = is_loop


var _m_sound_pool: _SoundPool
var _m_play_when_loaded_effects: Dictionary[int, _SoundInfoForLoadedCompleted]
var _m_left_volume: float
var _m_right_volume: float
var _m_path_sound_id_map: Dictionary[String, int]
var _m_path_stream_ids_map: Dictionary[String, Array]

func _init() -> void:
	_init_data()


func end() -> void:
	_m_sound_pool.release()
	remove_child(_m_sound_pool)
	_m_sound_pool.queue_free()
	_m_path_sound_id_map.clear()
	_m_path_stream_ids_map.clear()
	_m_play_when_loaded_effects.clear()
	_m_left_volume = 0.5
	_m_right_volume = 0.5
	_init_data()


func _init_data() -> void:
	_create_sound_pool()
	_m_sound_pool.set_on_load_complete_listener(func (_sound_pool: _SoundPool, sample_id: int, status: Error):
		if status == OK:
			var info: _SoundInfoForLoadedCompleted = _m_play_when_loaded_effects.get(sample_id)
			if info != null:
				info._effect_id = await _do_play_effect(info._path, sample_id, info._is_loop)
				info._played_when_loaded.emit())
	_m_left_volume = 0.5
	_m_right_volume = 0.5


func _create_sound_pool() -> void:
	_m_sound_pool = _SoundPool.new(5)
	add_child(_m_sound_pool)


func preload_effect(path: String) -> int:
	if path in _m_path_sound_id_map:
		return _m_path_sound_id_map[path]
	var sound_id := _create_sound_id_from_asset(path)
	if sound_id != -1:
		_m_path_sound_id_map[path] = sound_id
	return sound_id


func _create_sound_id_from_asset(path: String) -> int:
	return _m_sound_pool.load(path)


func unload_effect(path: String) -> void:
	if not path in _m_path_sound_id_map:
		return
	if path in _m_path_stream_ids_map:
		for stream_id in _m_path_stream_ids_map[path]:
			_m_sound_pool.stop(stream_id)
	_m_path_stream_ids_map.erase(path)
	_m_sound_pool.unload(_m_path_sound_id_map[path])
	_m_path_sound_id_map.erase(path)


func play_effect(path: String, is_loop: bool) -> int:
	if path in _m_path_sound_id_map:
		return await _do_play_effect(path, _m_path_sound_id_map[path], is_loop)
	else:
		var sound_id := preload_effect(path)
		if sound_id == -1:
			return -1
		var info := _SoundInfoForLoadedCompleted.new(path, is_loop)
		var play_when_loaded_effects := _m_play_when_loaded_effects # avoid accessing self after await
		play_when_loaded_effects.get_or_add(sound_id, info)
		await info._played_when_loaded
		play_when_loaded_effects.erase(sound_id)
		return info._effect_id


func _do_play_effect(path: String, sound_id: int, is_loop: bool) -> int:
	var stream_id := await _m_sound_pool.play(sound_id, _m_left_volume, _m_right_volume, -1 if is_loop else 0)
	var a: Array = _m_path_stream_ids_map.get_or_add(path, [])
	a.append(stream_id)
	return stream_id


func stop_all_effects() -> void:
	for a in _m_path_stream_ids_map.values():
		for stream_id in a:
			_m_sound_pool.stop(stream_id)
	_m_path_stream_ids_map.clear()


func stop_effect(stream_id: int) -> void:
	_m_sound_pool.stop(stream_id)
	for a in _m_path_stream_ids_map.values():
		a.erase(stream_id)


func pause_all_effects() -> void:
	_m_sound_pool.auto_pause()


func resume_all_effects() -> void:
	_m_sound_pool.auto_resume()


func get_effects_volume() -> float:
	return (_m_left_volume + _m_right_volume) / 2.0


func set_effects_volume(volume: float) -> void:
	volume = clampf(volume, 0.0, 1.0)
	_m_left_volume = volume
	_m_right_volume = volume
	for a in _m_path_stream_ids_map.values():
		for stream_id in a:
			_m_sound_pool.set_volume(stream_id, _m_left_volume, _m_right_volume)


func _on_enter_background() -> void:
	_m_sound_pool.auto_pause()


func _on_enter_foreground() -> void:
	_m_sound_pool.auto_resume()
