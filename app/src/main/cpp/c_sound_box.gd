
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")
const _NATIVE_LIB = preload("res://app/src/main/cpp/native-lib.gd")

static var _m_instance: _CSoundBox

var _se_volume := 100
var _music_volume := 100

static func get_instance() -> _CSoundBox:
	if _m_instance == null:
		_m_instance = _CSoundBox.new()
		_m_instance._init_sound_system()
	return _m_instance


static func destroy() -> void:
	if _m_instance != null:
		_m_instance._destroy_sound_system()
		_m_instance = null


func _init_sound_system() -> void:
	# does nothing in the original code
	pass


func _destroy_sound_system() -> void:
	_NATIVE_LIB.end_jni()


func update_sound() -> void:
	# does nothing in the original code
	pass


func load_music(path: String, _a2: String) -> void:
	_NATIVE_LIB.preload_background_music_jni(path)


func unload_music() -> void:
	# does nothing in the original code
	pass


func play_music(looping: bool) -> void:
	_NATIVE_LIB.play_background_music_jni(looping)


func resume_music() -> void:
	_NATIVE_LIB.resume_background_music_jni()


func _stop_music() -> void:
	_NATIVE_LIB.stop_background_music_jni()


func set_music_volume(volume: int) -> void:
	_music_volume = volume
	_NATIVE_LIB.set_background_music_volume_jni(volume / 100.0)


func load_se(path: String) -> void:
	_NATIVE_LIB.preload_effect_jni(path)


func unload_se(path: String) -> void:
	_NATIVE_LIB.unload_effect_jni(path)


func play_se(path: String) -> int:
	return await _NATIVE_LIB.play_effect_jni(path)


func _stop_all_se() -> void:
	_NATIVE_LIB.stop_all_effects_jni()


func set_se_volume(volume: int) -> void:
	_se_volume = volume
	_NATIVE_LIB.set_effects_volume_jni(volume / 100.0)
