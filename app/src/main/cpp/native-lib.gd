extends Node

const _Context = preload("res://core/java/android/content/context.gd")
const _AssetManager = preload("res://core/java/android/content/res/asset_manager.gd")
const _Wc2Activity = preload("res://app/src/main/java/com/easytech/wc2/wc2_activity.gd")
const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")
const _CStateManager = preload("res://app/src/main/cpp/c_state_manager.gd")
const _ecStringTable = preload("res://app/src/main/cpp/ec_string_table.gd")
const _CObjectDef = preload("res://app/src/main/cpp/c_object_def.gd")
const _CCommander = preload("res://app/src/main/cpp/c_commander.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")
const _ecUniFont = preload("res://app/src/main/cpp/ec_uni_font.gd")
const _ecMultipleTouch = preload("res://app/src/main/cpp/ec_multiple_touch.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")
const _Belligerent = preload("res://app/src/main/cpp/belligerent.gd")
const _SaveHeader = preload("res://app/src/main/cpp/save_header.gd")
const _SaveCountryInfo = preload("res://app/src/main/cpp/save_country_info.gd")

static var _asset_mgr: _AssetManager
static var _str_version_name: String
static var _document_file_path: String
static var _lang_dir: String

static func Java_com_easytech_wc2_Wc2Activity_nativeSetPaths(_context: _Context, asset_manager: _AssetManager, data_dir: String, lang_dir: String, version: String) -> void:
	# NOTTODO: store reference to classloader
	_asset_mgr = asset_manager
	_str_version_name = version
	_set_document_path(data_dir)
	_set_lang_dir(lang_dir)
	get_asset_path("Localizable.strings", "") # Part of the original game code but I don't think it does anything


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
	return get_asset_path(file_2x_name, _a2)

## renamed from get_path due to conflict with Engine method
static func get_asset_path(asset_name: String, extension: String) -> String:
	if not asset_name.is_empty():
		if not extension.is_empty():
			asset_name = asset_name + "." + extension
		if ResourceLoader.exists(asset_name):
			return asset_name
		else:
			var path := _lang_dir + '/' + asset_name
			if ResourceLoader.exists(path):
				return path
			else:
				return ""
	elif not extension.is_empty():
		for i in _asset_mgr.list(""):
			if i.get_extension() == extension:
				return i
	return ""


static var g_content_scale_factor := 1.0
static var g_font1: _ecUniFont
static var g_font2: _ecUniFont
static var g_font3: _ecUniFont
static var g_font6: _ecUniFont
static var g_font7: _ecUniFont
static var g_num1: _ecUniFont
static var g_num3: _ecUniFont
static var g_num4: _ecUniFont
static var g_num4b: _ecUniFont
static var g_num5: _ecUniFont
static var g_num8: _ecUniFont
static var _game_initialized := false
static var _s_time_offset: int # in ms
static var _m_old_time: int # in ms

static func Java_com_easytech_wc2_ecRenderer_nativeInit(game_view_width: int, game_view_height: int, _a3, _a4) -> void:
	var ratio = game_view_width as float / game_view_height as float
	var content_scale_width: int
	var content_scale_height: int
	if ratio > 1.8875: # never used. The aspect ratio is capped at 16:9.
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


static func _ec_game_init(content_scale_width: int, content_scale_height: int, orientation: int, game_view_width: int, game_view_height: int) -> void:
	set_ai_rand_seed(randi())
	set_rand_seed(randi())
	_ecGraphics.instance().init(content_scale_width, content_scale_height, orientation, game_view_width, game_view_height)
	# GUIManager is no longer a singleton, can't initialize here
	_CStateManager.instance().init()
	# NOTTODO: register states
	# set initial state as the main scene
	g_LocalizableStrings.load_table("Localizable.strings")
	var string_table_key: StringName
	if _ecGraphics.instance().content_scale_size_mode == 3:
		string_table_key = &"stringtable iPad"
	else:
		string_table_key = &"stringtable"
	var string_table_name := g_LocalizableStrings.get_string(string_table_key)
	g_StringTable.load_table(string_table_name)
	_CObjectDef.instance().init()
	g_Commander.load()
	_CSoundBox.get_instance().load_se("btn.wav")
	#g_font1.init("font1.fnt", false)
	#var language := g_LocalizableStrings.get_string("language")
	#if _ecGraphics.instance().content_scale_size_mode == 3:
		#g_font2.init("font2_{0}_hd.fnt".format([language]), false)
		#g_font3.init("font3_{0}_hd.fnt".format([language]), false)
		#if g_content_scale_factor == 2.0:
			#g_font6.init("font6_{0}_hd.fnt".format([language]), true)
			#g_num3.init("num3_hd.fnt", true)
			#g_num5.init("num5_hd.fnt", true)
		#else:
			#g_font6.init("font6_{0}.fnt".format([language]), false)
			#g_num3.init("num3.fnt", false)
			#g_num5.init("num5.fnt", false)
		#g_font7.init("font7_{0}_hd.fnt".format([language]), false)
		#g_num1.init("num1_hd.fnt", false)
		#g_num4.init("num4.fnt", false)
		#g_num4b.init("num4_hd.fnt", false)
	#elif g_content_scale_factor == 2.0:
		#g_font2.init("font2_{0}_hd.fnt".format([language]), true)
		#g_font3.init("font3_{0}_hd.fnt".format([language]), true)
		#g_font6.init("font6_{0}_hd.fnt".format([language]), true)
		#g_font7.init("font7_{0}_hd.fnt".format([language]), true)
		#g_num1.init("num1_hd.fnt", true)
		#g_num3.init("num3_hd.fnt", true)
		#g_num4.init("num4_hd.fnt", true)
		#g_num5.init("num5_hd.fnt", true)
		 ##g_num8.init("num8_hd.fnt", true) The original game code tries to load this font but it does not exist
	#else:
		#g_font2.init("font2_{0}.fnt".format([language]), false)
		#g_font3.init("font3_{0}.fnt".format([language]), false)
		#g_font6.init("font6_{0}.fnt".format([language]), false)
		#g_font7.init("font7_{0}.fnt".format([language]), false)
		#g_num1.init("num1.fnt", false)
		#g_num3.init("num3.fnt", false)
		#g_num4.init("num4.fnt", false)
		#g_num5.init("num5.fnt", false)
	g_font1 = load("res://app/src/main/cpp/resources/assets/font/g_font1.tres") as _ecUniFont
	g_font2 = load("res://app/src/main/cpp/resources/assets/font/g_font2.tres") as _ecUniFont
	g_font3 = load("res://app/src/main/cpp/resources/assets/font/g_font3.tres") as _ecUniFont
	g_font6 = load("res://app/src/main/cpp/resources/assets/font/g_font6.tres") as _ecUniFont
	g_font7 = load("res://app/src/main/cpp/resources/assets/font/g_font7.tres") as _ecUniFont
	g_num1 = load("res://app/src/main/cpp/resources/assets/font/g_num1.tres") as _ecUniFont
	g_num3 = load("res://app/src/main/cpp/resources/assets/font/g_num3.tres") as _ecUniFont
	g_num4 = load("res://app/src/main/cpp/resources/assets/font/g_num4.tres") as _ecUniFont
	g_num4b = load("res://app/src/main/cpp/resources/assets/font/g_num4b.tres") as _ecUniFont
	g_num5 = load("res://app/src/main/cpp/resources/assets/font/g_num5.tres") as _ecUniFont
	# NOTTODO: initialize iap items
	_game_initialized = true


static var _ai_rand_seed: int

static func set_ai_rand_seed(value: int) -> void:
	_ai_rand_seed = value


static func _get_ai_rand_seed() -> int:
	return _ai_rand_seed


static func get_ai_rand() -> int:
	_ai_rand_seed = 214013 * _ai_rand_seed + 2531011
	return (_ai_rand_seed >> 16) & 0x7FFF


static var _rand_seed: int

static func set_rand_seed(value: int) -> void:
	_rand_seed = value


static func get_rand_seed() -> int:
	return _rand_seed


static func get_rand() -> int:
	_rand_seed = 1103515245 * _rand_seed + 12345;
	return (_rand_seed >> 16) & 0x7FFF;


static func _get_time() -> int:
	return Time.get_ticks_msec()


static func Java_com_easytech_wc2_Wc2Activity_nativeDone() -> void:
	_ec_game_did_enter_background()
	_ec_game_shutdown()


static func _ec_game_shutdown() -> void:
	_game_initialized = false
	# TODO: finalize g_PlayerManager
	g_font1.release()
	g_font2.release()
	g_font3.release()
	g_font6.release()
	g_font7.release()
	g_num1.release()
	g_num3.release()
	g_num4.release()
	if _ecGraphics.instance().content_scale_size_mode == 3:
		g_num4b.release()
	g_num5.release()
	#g_num8.release()
	_CSoundBox.get_instance().unload_se("btn.wav")
	_CStateManager.instance().term()
	# no GUIManager
	_ecGraphics.instance().shutdown()
	_CSoundBox.destroy()
	_CObjectDef.instance().destroy()
	g_StringTable.clear()
	g_LocalizableStrings.clear()


static func end_jni() -> void:
	_Wc2Activity.end()


static var _game_paused := false:
	set(value):
		_game_paused = value
		_update_paused_fade()


static func Java_com_easytech_wc2_Wc2Activity_nativeResume() -> void:
	_ec_game_will_enter_foreground()
	_ec_game_resume()


static func _ec_game_will_enter_foreground() -> void:
	var sound_box := _CSoundBox.get_instance()
	sound_box.set_music_volume(g_GameSettings.music_volume)
	sound_box.set_se_volume(g_GameSettings.se_volume)
	sound_box.resume_music()
	_CStateManager.instance().enter_foreground()


static func _ec_game_resume() -> void:
	_game_paused = false


static func Java_com_easytech_wc2_Wc2Activity_nativePause() -> void:
	_ec_game_did_enter_background()
	_ec_game_pause()


static func _ec_game_did_enter_background() -> void:
	g_Commander.save()
	_CStateManager.instance().enter_background()


static func _ec_game_pause() -> void:
	_game_paused = true


static func Java_com_easytech_wc2_Wc2Activity_CallNativeExit() -> void:
	if not _ec_back_pressed():
		# Show exit handled by GUIMainMenu
		pass


static func _ec_back_pressed() -> bool:
	# no GUIManager
	return _CStateManager.instance().back_pressed()


static func Java_com_easytech_wc2_Wc2Activity_CallNativeError() -> void:
	# Unimplemented and eventually unused in the original game code
	pass


static func Java_com_easytech_wc2_Wc2Activity_AddMedal(medal: int) -> void:
	g_Commander.buy_medel(medal)
	g_Commander.save()


static var _game_waiting := false:
	set(value):
		_game_waiting = value
		_update_paused_fade()


static func Java_com_easytech_wc2_ecRenderer_nativeRender() -> void:
	var time := _get_time()
	var delta := clampf(0.001 * (time - _m_old_time), 0.0, 0.05)
	_s_time_offset = time
	_m_old_time = time
	_ec_game_update(delta)
	_ec_game_render()


static func _ec_game_update(_delta: float) -> void:
	if not _game_paused and not _game_waiting:
		# TODO: update PlayerManager
		# CStateManager is updated by callback as an autoload node
		# no GUIManager
		# GUIMotionManager is updated by callback as an autoload node
		# CSoundBox is updated by callback as an autoload node
		pass


static func _ec_game_render() -> void:
	# no global render target
	_CStateManager.instance().render()
	# no GUIManager
	# Fade out in black, a=0.5 when game paused or waiting. Handled by the following method, called by setters of _game_paused and _game_waiting.


static var _paused_fade_node: ColorRect

static func _update_paused_fade() -> void:
	var scene := Engine.get_main_loop() as SceneTree
	if _game_paused or _game_waiting:
		scene.paused = true
		if _paused_fade_node == null:
			_paused_fade_node = ColorRect.new()
			_paused_fade_node.set_anchors_preset(Control.PRESET_FULL_RECT)
			_paused_fade_node.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
			_paused_fade_node.color = Color(0.0, 0.0, 0.0, 0.5)
			scene.root.add_child(_paused_fade_node)
	else:
		scene.paused = false
		if _paused_fade_node != null:
			scene.root.remove_child(_paused_fade_node)
			_paused_fade_node.queue_free()
			_paused_fade_node = null


func _ec_game_waiting(value: bool) -> void:
	_game_waiting = value


static func Java_com_easytech_wc2_ecRenderer_nativeResize(_game_view_width: float, _game_view_height: float) -> void:
	# Unimplemented in the original game code
	pass


static func Java_com_easytech_wc2_ecRenderer_nativeTouch(touch_type: int, x: float, y: float, reset: int) -> void:
	var graphics := _ecGraphics.instance()
	if graphics.orientation == 2:
		y = graphics.orientated_content_scale_width - y
	elif graphics.orientation == 3:
		x = graphics.orientated_content_scale_height - x
	else:
		if graphics.orientation == 1:
			y = graphics.orientated_content_scale_height - y
		var tmp := x
		x = y
		y = tmp
	# no need to scale the coords, the root Viewport already did it
	var multiple_touch := _ecMultipleTouch.instance()
	if reset != 0:
		multiple_touch.reset()
	if touch_type == 0:
		var index := multiple_touch.touch_began(x, y)
		_ec_touch_begin(x, y, index)
	elif touch_type == 1:
		var index := multiple_touch.touch_ended(x, y)
		if index >= 0:
			_ec_touch_end(x, y, index)
	elif touch_type == 2:
		var index := multiple_touch.touch_moved(x, y)
		if index >= 0:
			_ec_touch_move(x, y, index)


static func _ec_touch_begin(x: float, y: float, index: int) -> void:
	if not _game_paused and not _game_waiting:
		# no GUIManager
		_CStateManager.instance().touch_begin(x, y, index)


static func _ec_touch_move(x: float, y: float, index: int) -> void:
	if not _game_paused and not _game_waiting:
		# no GUIManager
		_CStateManager.instance().touch_move(x, y, index)


static func _ec_touch_end(x: float, y: float, index: int) -> void:
	if not _game_paused and not _game_waiting:
		# no GUIManager
		_CStateManager.instance().touch_end(x, y, index)


static var _texture_with_string_queue: Array[Callable]
static var _texture_with_string_viewport: SubViewport
static var _texture_with_string_label: Label

static func ec_texture_with_string(string: String, font_name: String, font_size: int, alignment: int, width: int, height: int) -> _ecTexture:
	if _texture_with_string_viewport == null:
		_texture_with_string_viewport = SubViewport.new()
		_texture_with_string_label = Label.new()
		_texture_with_string_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		_texture_with_string_viewport.add_child(_texture_with_string_label)
		(Engine.get_main_loop() as SceneTree).root.add_child(_texture_with_string_viewport)
	var texture := ImageTexture.new()
	_texture_with_string_queue.push_back(func ():
		_texture_with_string_viewport.size = Vector2i(width, height)
		_texture_with_string_label.text = string
		_texture_with_string_label.get_theme_font(&"font").font_names = [font_name]
		_texture_with_string_label.remove_theme_font_size_override(&"font_size")
		_texture_with_string_label.add_theme_font_size_override(&"font_size", font_size)
		match alignment:
			1:
				_texture_with_string_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			2:
				_texture_with_string_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_:
				_texture_with_string_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_texture_with_string_label.draw.connect(func ():
			texture.set_image(_texture_with_string_viewport.get_texture().get_image())
			if not _texture_with_string_queue.is_empty():
				_texture_with_string_queue.pop_front().call()
			, CONNECT_DEFERRED | CONNECT_ONE_SHOT)
		)
	if _texture_with_string_queue.is_empty():
		_texture_with_string_queue.pop_front().call()
	var _ec_texture := _ecTexture.new()
	_ec_texture.texture = texture
	_ec_texture.w = width
	_ec_texture.h = height
	return _ec_texture


static func ec_texture_load(texture_name: String) -> _ecTexture:
	var path := ""
	var is_2x: bool
	if not Engine.is_editor_hint():
		if g_content_scale_factor == 2.0:
			path = get_2x_path(texture_name, "")
		is_2x = not path.is_empty()
		if not is_2x:
			path = get_asset_path(texture_name, "")
	else:
		path = get_asset_path(texture_name, "")
		is_2x = path.is_empty()
		if is_2x:
			path = get_2x_path(texture_name, "")
	if not ResourceLoader.exists(path):
		return null
	var texture := load(path) as Texture2D
	if texture == null:
		if not texture_name.ends_with(".png"):
			texture_name = texture_name.substr(0, texture_name.rfind(".")) + ".png"
			return ec_texture_load(texture_name)
		return null
	var ec_texture := _ecTexture.new()
	ec_texture.texture = texture
	if is_2x:
		ec_texture.size_override.x = texture.get_width() / 2.0
		ec_texture.size_override.y = texture.get_height() / 2.0
	else:
		ec_texture.size_override.x = texture.get_width()
		ec_texture.size_override.y = texture.get_height()
	return ec_texture


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


static var _dynamic_num_battles: Array[int]

static func get_num_battles(campaign: int) -> int:
	while _dynamic_num_battles.size() <= campaign:
		var i = 0
		while not get_asset_path(get_battle_file_name(1, campaign, i), "").is_empty():
			i += 1
		_dynamic_num_battles.append(i)
	return _dynamic_num_battles[campaign]


static func get_battle_file_name(game_mode: int, campaign: int, battle: int) -> String:
	match game_mode:
		1:
			match campaign:
				1:
					return "battle_allies{0}.xml".format([battle + 1])
				2:
					return "battle_wto{0}.xml".format([battle + 1])
				3:
					return "battle_nato{0}.xml".format([battle + 1])
				_:
					return "battle_axis{0}.xml".format([battle + 1])
		2:
			return "conquest_{0}.xml".format([battle + 1])
		4:
			return "multiplay_{0}.xml".format([battle + 1])
		5:
			return "tutorails.xml"
	return ""


static func get_battle_key_name(campaign: int, battle: int) -> String:
	match campaign:
		0:
			return "axis {0}".format([battle + 1])
		1:
			return "allies {0}".format([battle + 1])
		2:
			return "wto {0}".format([battle + 1])
		3:
			return "nato {0}".format([battle + 1])
		4:
			return "multiplay {0}".format([battle + 1])
	return ""


static func get_conquest_key_name(conquest: int) -> String:
	return "conquest {0}".format([conquest + 1])


static func get_battle_belligerent_list(battle_file_name: String, include_ai: bool) -> Array[_Belligerent]:
	var battle: SaveHeader = load(get_asset_path(battle_file_name, ""))
	var result: Array[_Belligerent]
	for i in battle.country:
		if i.alliance != 4 and (include_ai or not i.ai):
			var b := _Belligerent.new()
			b.id = i.id
			b.name = i.name
			b.commander = i.commander
			b.alliance = i.alliance
			result.append(b)
	return result


static func has_unit_motion(res: String, country_name: String) -> bool:
	var file_name := res + "_" + country_name
	if g_content_scale_factor == 2.0:
		return not get_asset_path(file_name + "_hd.xml", "").is_empty()\
			and not get_asset_path(file_name + "_hd.bin", "").is_empty()
	else:
		return not get_asset_path(file_name + ".xml", "").is_empty()\
			and not get_asset_path(file_name + ".bin", "").is_empty()


const _COMMANDER_ABILITY = [
	[0, 0, 0, 10, 5, 4],
	[0, 0, 0, 15, 10, 4],
	[0, 0, 0, 20, 15, 4],
	[1, 0, 0, 25, 20, 4],
	[1, 0, 0, 30, 25, 4],
	[1, 0, 1, 35, 30, 3],
	[1, 1, 2, 40, 35, 3],
	[1, 1, 3, 45, 40, 3],
	[1, 1, 4, 50, 45, 3],
	[2, 1, 5, 55, 50, 3],
	[2, 1, 6, 60, 55, 2],
	[2, 1, 7, 65, 60, 2],
	[3, 1, 8, 70, 65, 2],
	[3, 1, 9, 75, 70, 2],
	[3, 2, 10, 80, 75, 2],
]

static func get_commander_ability(level: int) -> Array[int]:
	if level > 14:
		level = 14
	return _COMMANDER_ABILITY[level]


const _ARMY_ABILITY = [
	[0, 0, 0, 0, 0],
	[1, 0, 0, 10, 0],
	[1, 1, 0, 20, 0],
	[1, 1, 0, 30, 20],
	[1, 1, 2, 40, 20],
]

static func get_army_ability(level: int) -> Array[int]:
	if level > 4:
		level = 4
	return _ARMY_ABILITY[level]


static func main_menu_loaded_jni() -> void:
	_Wc2Activity.main_menu_loaded()


static func app_java_exit() -> void:
	_Wc2Activity.java_exit()
