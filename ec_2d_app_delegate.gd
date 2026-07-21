class_name EC2dAppDelegate
extends Node

func _init() -> void:
	_application_will_finish_launching_with_options(Engine.get_main_loop(), {})


static var g_content_scale_factor: float = 1.0 / ProjectSettings.get_setting("display/window/stretch/scale")

func _application_will_finish_launching_with_options(_application: MainLoop, _launch_options: Dictionary) -> bool:
	var window_size := DisplayServer.window_get_size()
	var game_view_width := maxf(window_size.x, window_size.y)
	var game_view_height := minf(window_size.x, window_size.y)
	var ratio = game_view_width  / game_view_height
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
	@warning_ignore("narrowing_conversion")
	_ec_game_init(content_scale_width, content_scale_height, 0, game_view_width * g_content_scale_factor, game_view_height * g_content_scale_factor)
	# NOTTODO: assign callbacks for review and in app purchase
	return true


func _ec_game_init(content_scale_width: int, content_scale_height: int, orientation: int, game_view_width: int, game_view_height: int) -> void:
	set_ai_rand_seed(randi())
	set_rand_seed(randi())
	ecGraphics.instance().init(content_scale_width, content_scale_height, orientation, game_view_width, game_view_height)
	GUIManager.instance().init()
	var state_manager := CStateManager.instance()
	state_manager.init()
	(func ():
		await ready
		state_manager.register_state($CLogoState.create_instance())
		state_manager.register_state($CMenuState.create_instance())
		state_manager.register_state($CLoadState.create_instance())
		state_manager.register_state($CGameState.create_instance())
		state_manager.set_cur_state(EState.LOGO)).call()
	g_LocalizableStrings.load_table("Localizable.strings")
	var string_table_key: StringName
	if ecGraphics.instance().content_scale_size_mode == 3:
		string_table_key = &"stringtable iPad"
	else:
		string_table_key = &"stringtable"
	var string_table_name := g_LocalizableStrings.get_string(string_table_key)
	g_StringTable.load_table(string_table_name)
	CObjectDef.instance().init()
	g_Commander.load()
	CSoundBox.get_instance().load_se("btn.wav")
	g_Font1.init("font1.fnt", false)
	var language := g_LocalizableStrings.get_string("language")
	if ecGraphics.instance().content_scale_size_mode == 3:
		g_Font2.init("font2_{0}_hd.fnt".format([language]), false)
		g_Font3.init("font3_{0}_hd.fnt".format([language]), false)
		if g_content_scale_factor == 2.0:
			g_Font6.init("font6_{0}_hd.fnt".format([language]), true)
			g_Num3.init("num3_hd.fnt", true)
			g_Num5.init("num5_hd.fnt", true)
		else:
			g_Font6.init("font6_{0}.fnt".format([language]), false)
			g_Num3.init("num3.fnt", false)
			g_Num5.init("num5.fnt", false)
		g_Font7.init("font7_{0}_hd.fnt".format([language]), false)
		g_Num1.init("num1_hd.fnt", false)
		g_Num4.init("num4.fnt", false)
		g_Num4b.init("num4_hd.fnt", false)
	elif g_content_scale_factor == 2.0:
		g_Font2.init("font2_{0}_hd.fnt".format([language]), true)
		g_Font3.init("font3_{0}_hd.fnt".format([language]), true)
		g_Font6.init("font6_{0}_hd.fnt".format([language]), true)
		g_Font7.init("font7_{0}_hd.fnt".format([language]), true)
		g_Num1.init("num1_hd.fnt", true)
		g_Num3.init("num3_hd.fnt", true)
		g_Num4.init("num4_hd.fnt", true)
		g_Num4b.init("num4_hd.fnt", true)
		g_Num5.init("num5_hd.fnt", true)
		#g_Num8.init("num8_hd.fnt", true) The original game code tries to load this font but it does not exist
	else:
		g_Font2.init("font2_{0}.fnt".format([language]), false)
		g_Font3.init("font3_{0}.fnt".format([language]), false)
		g_Font6.init("font6_{0}.fnt".format([language]), false)
		g_Font7.init("font7_{0}.fnt".format([language]), false)
		g_Num1.init("num1.fnt", false)
		g_Num3.init("num3.fnt", false)
		g_Num4.init("num4.fnt", false)
		g_Num4b.init("num4.fnt", false)
		g_Num5.init("num5.fnt", false)
	# NOTTODO: initialize iap items


var _ai_rand_seed: int

func set_ai_rand_seed(value: int) -> void:
	_ai_rand_seed = value


func _get_ai_rand_seed() -> int:
	return _ai_rand_seed


func get_ai_rand() -> int:
	_ai_rand_seed = 214013 * _ai_rand_seed + 2531011
	return (_ai_rand_seed >> 16) & 0x7FFF


var _rand_seed: int

func set_rand_seed(value: int) -> void:
	_rand_seed = value


func get_rand_seed() -> int:
	return _rand_seed


func get_rand() -> int:
	_rand_seed = 1103515245 * _rand_seed + 12345;
	return (_rand_seed >> 16) & 0x7FFF;


func _notification(what):
	if Engine.is_editor_hint():
		return
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_application_will_terminate(Engine.get_main_loop())
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		_application_did_enter_background(Engine.get_main_loop())
		get_tree().paused = true
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		_application_will_enter_foreground(Engine.get_main_loop())
		get_tree().paused = false
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		var event := InputEventAction.new()
		event.action = &"ui_cancel"
		event.pressed = true
		Input.parse_input_event(event)


func _application_will_terminate(_application: MainLoop) -> void:
	# TODO: finalize g_PlayerManager
	g_Font1.release()
	g_Font2.release()
	g_Font3.release()
	g_Font6.release()
	g_Font7.release()
	g_Num1.release()
	g_Num3.release()
	g_Num4.release()
	g_Num4b.release()
	g_Num5.release()
	#g_Num8.release()
	CSoundBox.get_instance().unload_se("btn.wav")
	#_CStateManager.instance().term()
	# no GUIManager
	ecGraphics.instance().shutdown()
	CSoundBox.destroy()
	CObjectDef.instance().destroy()
	g_StringTable.clear()
	g_LocalizableStrings.clear()


func _application_did_enter_background(_application: MainLoop) -> void:
	g_Commander.save()


func _application_will_enter_foreground(_application: MainLoop) -> void:
	pass


static func get_document_path(file_name: String) -> String:
	return "user://" + file_name


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
		var path := "res://assets/" + asset_name
		if ResourceLoader.exists(path):
			return path
		else:
			path = 'res://assets/English.lproj/' + asset_name
			if ResourceLoader.exists(path):
				return path
			else:
				return ""
	elif not extension.is_empty():
		var li := ResourceLoader.list_directory("res://")
		li.append_array(ResourceLoader.list_directory("res://English.lproj/"))
		for i in li:
			if i.get_extension() == extension:
				return i
	return ""

var _texture_with_string_queue: Array[Callable]
var _texture_with_string_viewport: SubViewport
var _texture_with_string_label: Label

func ec_texture_with_string(string: String, font_name: String, font_size: int, alignment: int, width: int, height: int) -> ecTexture:
	if _texture_with_string_viewport == null:
		_texture_with_string_viewport = SubViewport.new()
		_texture_with_string_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
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
		_texture_with_string_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		(func ():
			texture.set_image(_texture_with_string_viewport.get_texture().get_image())
			if not _texture_with_string_queue.is_empty():
				_texture_with_string_queue.pop_front().call()
			).call_deferred()
		)
	if _texture_with_string_queue.is_empty():
		_texture_with_string_queue.pop_front().call()
	var _ec_texture := ecTexture.new()
	_ec_texture.texture = texture
	_ec_texture.w = width
	_ec_texture.h = height
	return _ec_texture


static func ec_texture_load(texture_name: String) -> ecTexture:
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
		if not texture_name.ends_with(".png"):
			texture_name = texture_name.substr(0, texture_name.rfind(".")) + ".png"
			return ec_texture_load(texture_name)
		return null
	if Engine.is_editor_hint():
		var texture: Texture2D = null
		texture = load(path) as Texture2D
		var ec_texture := ecTexture.new()
		ec_texture.texture = texture
		if is_2x:
			ec_texture.size_override = texture.get_size() / 2
		else:
			ec_texture.size_override = texture.get_size()
		return ec_texture
	else:
		if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			ResourceLoader.load_threaded_request(path)
		var ec_texture := ecTexture.new()
		(func ():
			var status := ResourceLoader.load_threaded_get_status(path)
			while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				await (Engine.get_main_loop() as SceneTree).process_frame
				status = ResourceLoader.load_threaded_get_status(path)
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				var texture = ResourceLoader.load_threaded_get(path)
				ec_texture.texture = texture
				if is_2x:
					ec_texture.size_override = texture.get_size() / 2
				else:
					ec_texture.size_override = texture.get_size()
			).call_deferred()
		return ec_texture


var _dynamic_num_battles: Array[int]

func get_num_battles(campaign: int) -> int:
	while _dynamic_num_battles.size() <= campaign:
		var i = 0
		while not get_asset_path(get_battle_file_name(1, campaign, i), "").is_empty():
			i += 1
		_dynamic_num_battles.append(i)
	return _dynamic_num_battles[campaign]


func get_battle_file_name(game_mode: int, campaign: int, battle: int) -> String:
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


func get_battle_key_name(campaign: int, battle: int) -> String:
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


func get_conquest_key_name(conquest: int) -> String:
	return "conquest {0}".format([conquest + 1])


func get_battle_belligerent_list(battle_file_name: String, include_ai: bool) -> Array[Belligerent]:
	var battle: SaveHeader = load(get_asset_path(battle_file_name, ""))
	var result: Array[Belligerent]
	for i in battle.country:
		if i.alliance != 4 and (include_ai or not i.ai):
			var b := Belligerent.new()
			b.id = i.id
			b.name = i.name
			b.commander = i.commander
			b.alliance = i.alliance
			result.append(b)
	return result


func has_unit_motion(res: String, country_name: String) -> bool:
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

func get_commander_ability(level: int) -> Array[int]:
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

func get_army_ability(level: int) -> Array[int]:
	if level > 4:
		level = 4
	return _ARMY_ABILITY[level]
