
const _Context = preload("res://core/java/android/content/context.gd")
const _Wc2Activity = preload("res://app/src/main/java/com/easytech/wc2/wc2_activity.gd")
const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")
const _CStateManager = preload("res://app/src/main/cpp/c_state_manager.gd")
const _ecStringTable = preload("res://app/src/main/cpp/ec_string_table.gd")
const _CObjectDef = preload("res://app/src/main/cpp/c_object_def.gd")
const _CCommander = preload("res://app/src/main/cpp/c_commander.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")
const _ecUniFont = preload("res://app/src/main/cpp/ec_uni_font.gd")

static var _str_version_name: String
static var _document_file_path: String
static var _lang_dir: String

static func Java_com_easytech_wc2_Wc2Activity_nativeSetPaths(context: _Context, resource_loader, data_dir: String, lang_dir: String, version: String) -> void:
	# NOTTODO: store reference to classloader and assetmanager
	_str_version_name = version
	_set_document_path(data_dir)
	_set_lang_dir(lang_dir)
	get_path("Localizable.strings", "") # Part of the original game code but I don't think it does anything


static func _set_document_path(path: String) -> void:
	_document_file_path = "{0}/".format([path])


static func get_document_path(file_name: String) -> String:
	return "{0}/{1}".format([_document_file_path, file_name])


static func _set_lang_dir(dir: String) -> void:
	_lang_dir = dir


static func get_2x_path(file_name: String, _a2: String) -> String:
	var file_2x_name: String
	var i := file_name.find('.')
	while i != -1:
		file_2x_name = file_name.insert(i, "@2x")
		i = file_name.find('.', i + 1)
	return get_path(file_2x_name, _a2)


static func get_path(file_name: String, _a2: String) -> String:
	var path := file_name
	if ResourceLoader.exists(path) or FileAccess.file_exists(path):
		return path
	else:
		path = _lang_dir + '/' + file_name
		if ResourceLoader.exists(path) or FileAccess.file_exists(path):
			return path
		else:
			return ""


static var g_content_scale_factor := 1.0
static var g_localizable_strings := _ecStringTable.new()
static var g_string_table := _ecStringTable.new()
static var g_commander := _CCommander.new()
static var g_font1 := _ecUniFont.new()
static var g_font2 := _ecUniFont.new()
static var g_font3 := _ecUniFont.new()
static var g_font6 := _ecUniFont.new()
static var g_font7 := _ecUniFont.new()
static var g_num1 := _ecUniFont.new()
static var g_num3 := _ecUniFont.new()
static var g_num4 := _ecUniFont.new()
static var g_num4b := _ecUniFont.new()
static var g_num5 := _ecUniFont.new()
static var g_num8 := _ecUniFont.new()
static var _game_initialized := false
static var _s_time_offset: int # in ms
static var _m_old_time: int # in ms

static func Java_com_easytech_wc2_ecRenderer_nativeInit(game_view_width: float, game_view_height: float, _a3, _a4) -> void:
	var ratio = game_view_width / game_view_height
	var content_scale_width: float
	var content_scale_height: float
	if ratio > 1.8875:
		content_scale_width = 640
		content_scale_height = 320
	elif ratio > 1.7219:
		content_scale_width = 568
		content_scale_height = 320
	elif ratio > 1.5844:
		content_scale_width = 534
		content_scale_height = 320
	elif ratio >= 1.4062:
		content_scale_width = 480
		content_scale_height = 320
	else:
		content_scale_width = 1024
		content_scale_height = 768
	g_content_scale_factor = 2.0
	_ec_game_init(content_scale_width, content_scale_height, 0, game_view_width, game_view_height)
	_s_time_offset = 0
	_m_old_time = _get_time()
	# NOTTODO: assign a callback that is triggered when an in app purchase is performed


static func _ec_game_init(content_scale_width: float, content_scale_height: float, orientation: int, game_view_width: float, game_view_height: float) -> void:
	_set_ai_rand_seed(randi())
	_set_rand_seed(randi())
	_ecGraphics.instance().init(content_scale_width, content_scale_height, orientation, game_view_width, game_view_height)
	# GUIManager is no longer a singleton, can't initialize here
	_CStateManager.instance().init()
	# TODO: register and set initial state
	g_localizable_strings.load("Localizable.strings")
	var string_table_key: StringName
	if _ecGraphics.instance()._content_scale_size_mode == 3:
		string_table_key = &"stringtable iPad"
	else:
		string_table_key = &"stringtable"
	var string_table_name := g_localizable_strings.get_string(string_table_key)
	g_string_table.load(string_table_name)
	TranslationServer.add_translation(g_string_table._translation)
	_CObjectDef.instance().init()
	g_commander.load()
	_CSoundBox.get_instance().load_se("btn.wav")
	g_font1.init("font1.fnt", false)
	var language := g_localizable_strings.get_string("language")
	if _ecGraphics.instance().widthMode == 3:
		g_font2.init("font2_{0}_hd.fnt".format([language]), false)
		g_font3.init("font3_{0}_hd.fnt".format([language]), false)
		if g_content_scale_factor == 2.0:
			g_font6.init("font6_{0}_hd.fnt".format([language]), true)
			g_num3.init("num3_hd.fnt", true)
			g_num5.init("num5_hd.fnt", true)
		else:
			g_font6.init("font6_{0}.fnt".format([language]), false)
			g_num3.init("num3.fnt", false)
			g_num5.init("num5.fnt", false)
		g_font7.init("font7_{0}_hd.fnt".format([language]), false)
		g_num1.init("num1_hd.fnt", false)
		g_num4.init("num4.fnt", false)
		g_num4b.init("num4_hd.fnt", false)
	elif g_content_scale_factor == 2.0:
		g_font2.init("font2_{0}_hd.fnt".format([language]), true)
		g_font3.init("font3_{0}_hd.fnt".format([language]), true)
		g_font6.init("font6_{0}_hd.fnt".format([language]), true)
		g_font7.init("font7_{0}_hd.fnt".format([language]), true)
		g_num1.init("num1_hd.fnt", true)
		g_num3.init("num3_hd.fnt", true)
		g_num4.init("num4_hd.fnt", true)
		g_num5.init("num5_hd.fnt", true)
		g_num8.init("num8_hd.fnt", true)
	else:
		g_font2.init("font2_{0}.fnt".format([language]), false)
		g_font3.init("font3_{0}.fnt".format([language]), false)
		g_font6.init("font6_{0}.fnt".format([language]), false)
		g_font7.init("font7_{0}.fnt".format([language]), false)
		g_num1.init("num1.fnt", false)
		g_num3.init("num3.fnt", false)
		g_num4.init("num4.fnt", false)
		g_num5.init("num5.fnt", false)
	# NOTTODO: initialize iap items
	_game_initialized = true


static var _ai_rand_seed: int

static func _set_ai_rand_seed(seed: int) -> void:
	_ai_rand_seed = seed


static func get_ai_rand_seed() -> int:
	return _ai_rand_seed


static func get_ai_rand() -> int:
	_ai_rand_seed = 214013 * _ai_rand_seed + 2531011
	return (_ai_rand_seed >> 16) & 0x7FFF


static var _rand_seed: int

static func _set_rand_seed(seed: int) -> void:
	_rand_seed = seed


static func get_rand_seed() -> int:
	return _rand_seed


static func  get_rand() -> int:
	_rand_seed = 1103515245 * _rand_seed + 12345;
	return (_rand_seed >> 16) & 0x7FFF;


static func _get_time() -> int:
	return Time.get_ticks_msec()


static func Java_com_easytech_wc2_Wc2Activity_nativeDone() -> void:
	_ec_game_did_enter_background()
	_ec_game_shutdown()


static func end_jni() -> void:
	_Wc2Activity.end()


static func _ec_game_did_enter_background() -> void:
	pass


static func _ec_game_shutdown() -> void:
	# TODO: a lot of finalization
	_ecGraphics.instance().shutdown()
	# TODO: more finalization


static func Java_com_easytech_wc2_Wc2Activity_nativeResume() -> void:
	pass


static func Java_com_easytech_wc2_Wc2Activity_nativePause() -> void:
	pass


static func Java_com_easytech_wc2_Wc2Activity_CallNativeExit() -> void:
	pass


static func Java_com_easytech_wc2_Wc2Activity_CallNativeError() -> void:
	# Unimplemented and eventually unused in the original game code
	pass


static func Java_com_easytech_wc2_Wc2Activity_AddMedal(medal: int) -> void:
	pass


static func Java_com_easytech_wc2_ecRenderer_nativeRender() -> void:
	pass


static func Java_com_easytech_wc2_ecRenderer_nativeResize(game_view_width: float, game_view_height: float) -> void:
	pass


static func Java_com_easytech_wc2_ecRenderer_nativeTouch(touch_type: int, x: float, y: float, reset: int) -> void:
	pass


static func ec_texture_with_string(a1: String, a2: String, a3: int, a4: int, r_width: Array[int], r_height: Array[int], r_texture: Array[Texture]) -> bool:
	# Unimplemented and eventually unused in the original game code
	return false


static func ec_texture_load(texture_name: String, r_width: Array[int], r_height: Array[int], r_texture: Array[Texture2D]) -> bool:
	var path := ""
	if g_content_scale_factor == 2.0:
		path = get_2x_path(texture_name, "")
	if path == "":
		path = get_path(texture_name, "")
	var texture := load(path) as Texture2D
	if texture == null:
		if not texture_name.ends_with(".png"):
			texture_name = texture_name.substr(0, texture_name.rfind(".")) + ".png"
			return ec_texture_load(texture_name, r_width, r_height, r_texture)
		return false
	r_texture.append(texture)
	r_width.append(texture.get_width())
	r_height.append(texture.get_height())
	return true


static func preload_background_music_jni(path: String) -> void:
	_Wc2Activity.preload_background_music(path)


static func play_background_music_jni(looping: bool) -> void:
	_Wc2Activity.play_background_music(looping)


static func pause_background_music_jni() -> void:
	_Wc2Activity.pause_background_music()


static func resume_background_music_jni() -> void:
	_Wc2Activity.resume_background_music()


static func stop_background_music_jni() -> void:
	_Wc2Activity.stop_background_music()


static func get_background_music_volume_jni() -> float:
	return _Wc2Activity.get_background_music_volume()


static func set_background_music_volume_jni(volume: float) -> void:
	_Wc2Activity.set_background_music_volume(volume)


static func preload_effect_jni(path: String) -> void:
	_Wc2Activity.preload_effect(path)


static func unload_effect_jni(path: String) -> void:
	_Wc2Activity.unload_effect(path)


static func play_effect_jni(path: String) -> int:
	return await _Wc2Activity.play_effect(path)


static func stop_all_effects_jni() -> void:
	_Wc2Activity.stop_all_effects()


static func get_effects_volume_jni() -> float:
	return _Wc2Activity.get_effects_volume()


static func set_effects_volume_jni(volume: float) -> void:
	_Wc2Activity.set_effects_volume(volume)
