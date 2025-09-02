extends "res://core/java/android/app/activity.gd"

## An Activity in Android development is similar to a scene in Godot. It is the
## primary controller of an App and can be switched to another.
##
## Wc2Activity is the only Activity class implemented in the original Java game
## code. It provides the following functionalities:
## 1. managing the life cycle of the game (starting, pausing etc.)
## 2. loading libworld-conqueror-2.so the native library
## 3. detecting system language and setting up localization
## 4. setting the position and size of the entire game view
## 5. hiding the system navigation ui
## 6. providing a callback that is triggered when the back button is pressed
## 7. bridging the call from native code to other java methods to:
##     7.1 play background music and sound effects
##     7.2 handle in game purchase
## 
## In this Godot port, 7.2 is obviously not implemented. And because the states
## take the position of main scenes from Activity, 4. and 6. are mostly
## irrelevant. To learn about states, see
## "res://app/src/main/cpp/c_state_manager.gd"

const _R = preload("res://app/src/main/java/com/easytech/wc2/r.gd")
const _ecGLSurfaceView = preload("res://app/src/main/java/com/easytech/wc2/ec_gl_surface_view.gd")
const _ecRenderer = preload("res://app/src/main/java/com/easytech/wc2/ec_renderer.gd")
const _ViewGroup = preload("res://core/java/android/view/view_group.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _Context = preload("res://core/java/android/content/context.gd")
const _Activity = preload("res://core/java/android/app/activity.gd")
const _Wc2Activity = preload("res://app/src/main/java/com/easytech/wc2/wc2_activity.gd")
const _ecMusic = preload("res://app/src/main/java/com/easytech/wc2/ec_music.gd")
const _ecSound = preload("res://app/src/main/java/com/easytech/wc2/ec_sound.gd")

class _ReferenceToCallable:
	extends Object # Disable reference counting since this class is intended for a callable to refer to itself
	
	var ref: Callable


static var _m_game_view_width: int
static var _m_game_view_height: int
static var _m_gl_view: _ecGLSurfaceView
static var _object_context: _Context
static var _object_activity: _Wc2Activity
static var _is_first_time := false
static var _background_music_player: _ecMusic
static var _sound_player: _ecSound

func _on_create() -> void:
	super._on_create()
	set_content_view(_R.layout.background)
	_prepare_view_size(false)
	_object_context = self
	_object_activity = self
	# NOTTODO: create objects for iap, google play and customer service
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	# NOTTODO: get device identity, build model and package name
	_set_package_name(self)
	var tween := create_tween()
	tween.tween_interval(3.0)
	tween.tween_callback(func (): _hide_system_ui())
	_background_music_player = _ecMusic.new()
	add_child(_background_music_player)
	_sound_player = _ecSound.new()
	add_child(_sound_player)
	# NOTTODO: initialize iap
	_get_view_size()


func _prepare_view_size(show_game_view: bool) -> void:
	var view := find_view_by_id(_R.id.main_layout)
	var listener := _ReferenceToCallable.new()
	listener.ref = (func ():
		view.get_view_tree_observer().remove_on_global_layout_listener(listener.ref)
		listener.free()
		var width := view.get_measured_width()
		var height := view.get_measured_height()
		(func ():
			if height <= width:
				_m_game_view_width = width
				_m_game_view_height = height
			else:
				_m_game_view_width = height
				_m_game_view_height = width
			if show_game_view:
				_show_game_view(height, width)
		).call_deferred()
	)
	view.get_view_tree_observer().add_on_global_layout_listener(listener.ref)


func _show_game_view(_width: float, _height: float) -> void:
	# NOTTODO: adjust view size according to build version and model
	@warning_ignore("integer_division")
	var height_16_9 := (_m_game_view_height * 16) / 9
	if _m_game_view_width > height_16_9:
		_m_game_view_width = height_16_9
		get_viewport().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	else:
		get_viewport().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE
	_ecRenderer.is_app_running = true
	_m_gl_view = _ecGLSurfaceView.new()
	_m_gl_view.size = Vector2(_m_game_view_width, _m_game_view_height)
	(find_view_by_id(_R.id.main_layout) as _ViewGroup).add_view(_m_gl_view)
	_m_gl_view.set_anchors_preset(Control.PRESET_CENTER)
	DisplayServer.screen_set_keep_on(true)
	# NOTTODO: get promotion info from google play


func _set_package_name(context: _Context) -> void:
	# NOTTODO: store package name
	var data_dir := "user://"
	var locale := OS.get_locale().to_upper()
	var lang_dir: String
	if locale.contains("_CN") or locale.ends_with("#HANS"):
		lang_dir = "zh_CN.lproj"
	elif locale.contains("_TW") or locale.ends_with("#HANT") or locale.ends_with("ZH_HK"):
		lang_dir = "zh_TW.lproj"
	elif locale.contains("_JP"):
		lang_dir = "ja.lproj"
	elif locale.contains("_KR") or locale == "KO_KP":
		lang_dir = "kr.lproj"
	elif locale.contains("_RU"):
		lang_dir = "ru.lproj"
	else:
		lang_dir = "English.lproj"
	var version:String = ProjectSettings.get_setting("application/config/version")
	_native_set_path(context, ResourceLoader, data_dir, lang_dir, version)


func _hide_system_ui() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


static func _native_set_path(context: _Context, resource_loader, data_dir: String, lang_dir: String, version: String) ->void:
	_native.Java_com_easytech_wc2_Wc2Activity_nativeSetPaths(context, resource_loader, data_dir, lang_dir, version)


func _get_view_size() -> void:
	if _m_game_view_width == 0.0 or _m_game_view_height == 0.0:
		_prepare_view_size(true)
	else:
		_show_game_view(_m_game_view_width, _m_game_view_height)


func _on_destroy() -> void:
	super._on_destroy()
	if _m_gl_view != null:
		_native_done.call_deferred()


static func _native_done() -> void:
	_native.Java_com_easytech_wc2_Wc2Activity_nativeDone()


func _on_start() -> void:
	super._on_start()


func _on_stop() -> void:
	super._on_stop()


func _on_resume() -> void:
	super._on_resume()
	if _m_gl_view != null:
		_ecRenderer.is_app_running = true
		resume_background_music()
		_native_resume.call_deferred()


static func _native_resume() -> void:
	_native.Java_com_easytech_wc2_Wc2Activity_nativeResume()


func _on_pause() -> void:
	super._on_pause()
	if _m_gl_view != null:
		pause_background_music()
		_native_pause.call_deferred()
		_ecRenderer.is_app_running = false


static func _native_pause() -> void:
	_native.Java_com_easytech_wc2_Wc2Activity_nativePause()


func _on_key_down(key_code: int, event: InputEvent) -> bool:
	if key_code != 4:
		return super._on_key_down(key_code, event)
	if _m_gl_view != null:
		_call_native_exit.call_deferred()
	return true


static func _call_native_exit() -> void:
	_native.Java_com_easytech_wc2_Wc2Activity_CallNativeExit()


func _on_windows_focus_changed(has_focus: bool) -> void:
	if has_focus:
		_hide_system_ui()


static func _call_native_error() -> void:
	_native.Java_com_easytech_wc2_Wc2Activity_CallNativeError()


static func main_menu_loaded() -> void:
	if not _is_first_time:
		_is_first_time = true
	# NOTTODO: Get prices of iap itemss


static func end() -> void:
	_background_music_player.end()
	_sound_player.end()


static func java_exit() -> void:
	_ecRenderer.is_app_running = false
	get_activity().finish()


static func rtn_activity() -> Object:
	return _object_context


static func get_context() -> _Context:
	return _object_context


static func get_activity() -> _Activity:
	return _object_activity


static func get_game_activity() -> _Wc2Activity:
	return _object_activity


static func get_view_width() -> int:
	return _m_game_view_width


static func get_view_height() -> int:
	return _m_game_view_height


static func get_game_view() -> _ecGLSurfaceView:
	return _m_gl_view


static func preload_background_music(path: String) -> void:
	_background_music_player.preload_background_music(path)


static func play_background_music(looping: bool) -> void:
	_background_music_player.play_background_music(looping)


static func pause_background_music() -> void:
	_background_music_player.pause_background_music()


static func resume_background_music() -> void:
	_background_music_player.resume_background_music()


static func stop_background_music() -> void:
	_background_music_player.stop_background_music()


static func get_background_music_volume() -> float:
	return _background_music_player.get_background_volume()


static func set_background_music_volume(volume: float) -> void:
	_background_music_player.set_background_volume(volume)


static func preload_effect(path: String) -> void:
	_sound_player.preload_effect(path)


static func unload_effect(path: String) -> void:
	_sound_player.unload_effect(path)


static func play_effect(path: String) -> int:
	return await _sound_player.play_effect(path, false)


static func stop_all_effects() -> void:
	_sound_player.stop_all_effects()


static func get_effects_volume() -> float:
	return _sound_player.get_effects_volume()


static func set_effects_volume(volume: float) -> void:
	_sound_player.set_effects_volume(volume)


static func add_medal(medal: int) -> void:
	_native.Java_com_easytech_wc2_Wc2Activity_AddMedal(medal)
