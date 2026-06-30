extends "res://app/src/main/cpp/native-lib.gd"

var _se_volume := 100
var _music_volume := 100

static func get_instance() -> _CSoundBox:
	#if _m_instance == null:
		#_m_instance = _CSoundBox.new()
		#_m_instance._init_sound_system()
	return CSoundBox


static func destroy() -> void:
	#if _m_instance != null:
		#_m_instance._destroy_sound_system()
		#_m_instance = null
	CSoundBox._destroy_sound_system()


func _init_sound_system() -> void:
	# does nothing in the original code
	pass


func _destroy_sound_system() -> void:
	end_jni()


func update_sound() -> void:
	# does nothing in the original code
	pass


func load_music(path: String, extension: String) -> void:
	preload_background_music_jni(get_asset_path(path, extension))


func unload_music() -> void:
	# does nothing in the original code
	pass


func play_music(looping: bool) -> void:
	play_background_music_jni(looping)


func resume_music() -> void:
	resume_background_music_jni()


func _stop_music() -> void:
	stop_background_music_jni()


func set_music_volume(volume: int) -> void:
	_music_volume = volume
	set_background_music_volume_jni(volume / 100.0)


func load_se(path: String) -> void:
	preload_effect_jni(path)


func unload_se(path: String) -> void:
	unload_effect_jni(path)


func play_se(path: String) -> int:
	return await play_effect_jni(path)


func _stop_all_se() -> void:
	stop_all_effects_jni()


func set_se_volume(volume: int) -> void:
	_se_volume = volume
	set_effects_volume_jni(volume / 100.0)


func _process(_delta: float) -> void:
	update_sound()
