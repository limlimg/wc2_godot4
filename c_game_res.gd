extends Node

var _army_res: ecTextureRes
var _image_hp_bar: Texture2D
var _image_hp_bar_fill: Texture2D
var arrow_green: Texture2D
var arrow_yellow: Texture2D
var arrow_blue: Texture2D
var arrow_red: Texture2D
var arrow_shadow: Texture2D
var _image_build_mark_airport: Texture2D
var _image_build_mark_port: Texture2D
var _cardtex_res: ecTextureRes
var card_d_research: Dictionary[int, Texture2D]
var _battlebg_res: ecTextureRes
var _flag_res: ecTextureRes
var _eff_res: ecTextureRes
var _effect_cache: Array[ecEffectRes]

func load_res() -> void:
	_army_res = load("res://resources/assets/game_res/army.tres")
	_cardtex_res = load("res://resources/assets/game_res/cardtex.tres")
	_image_hp_bar = _army_res.get_image(&"hpbar.png")
	var hp_bar_fill = _army_res.get_image(&"hpbar_fill.png")
	_image_hp_bar_fill = hp_bar_fill.duplicate()
	_image_hp_bar_fill.texture = hp_bar_fill.texture
	_image_hp_bar_fill.region.position.x += 1.0
	_image_hp_bar_fill.region.size.x = 1.0
	arrow_green = _army_res.get_image(&"arrow_green.png")
	arrow_yellow = _army_res.get_image(&"arrow_yellow.png")
	arrow_blue = _army_res.get_image(&"arrow_blue.png")
	arrow_red = _army_res.get_image(&"arrow_red.png")
	arrow_shadow = _army_res.get_image(&"arrowshadow.png")
	_image_build_mark_airport = _army_res.get_image(&"buildmark_airport.png")
	_image_build_mark_port = _army_res.get_image(&"buildmark_port.png")
	var regex_card_d_research := RegEx.create_from_string("card_d_research_([0-9]+).png")
	for i in _cardtex_res.get_keys():
		var regex_match: RegExMatch
		regex_match = regex_card_d_research.search(i)
		if regex_match != null:
			card_d_research[regex_match.get_string(1).to_int()] = _cardtex_res.get_image(i)
	_battlebg_res = load("res://resources/assets/game_res/battlebg.tres")
	_flag_res = load("res://resources/assets/game_res/flag.tres")
	_eff_res = load("res://resources/assets/game_res/eff.tres")
	_effect_cache = [
		load("res://resources/assets/game_res/effect_airstrike.tres"),
		load("res://resources/assets/game_res/effect_exp.tres"),
		load("res://resources/assets/game_res/effect_fortfire.tres"),
		load("res://resources/assets/game_res/effect_gunfire.tres"),
		load("res://resources/assets/game_res/effect_mgunfire.tres"),
		load("res://resources/assets/game_res/effect_nuclearbomb.tres"),
		load("res://resources/assets/game_res/effect_parachute.tres"),
		load("res://resources/assets/game_res/effect_shipfire.tres"),
		load("res://resources/assets/game_res/effect_strike1.tres"),
		load("res://resources/assets/game_res/effect_strike2.tres"),
		load("res://resources/assets/game_res/effect_strike3.tres"),
		load("res://resources/assets/game_res/effect_strike4.tres"),
		load("res://resources/assets/game_res/effect_strike5.tres"),
		load("res://resources/assets/game_res/effect_tankfire.tres")
	]


func render_flag(to_canvas_item: RID, country_name: StringName, x: float, y: float)-> void:
	_army_res.get_image("flag_{0}.png".format([country_name])).draw(to_canvas_item, Vector2(x, y))


func render_ui_defend_army(to_canvas_item: RID, country_name: StringName, x: float, y: float, id: int, strength: int, max_strength: int, movement: int, cards: int, level: int, alliance: int, ai: bool) -> void:
	var army := _get_army_image(country_name, id, false)
	if army != null:
		army.draw_rect(to_canvas_item, Rect2(x, y, -army.get_width(), army.get_height()), false)
	_image_hp_bar.draw(to_canvas_item, Vector2(x - 30.0, y - 12.0))
	var hp_ratio := strength as float / max_strength
	var hp_color := Color(minf(2 - 2 * hp_ratio, 1.0), minf(2 * hp_ratio, 1.0), maxf(hp_ratio - 0.5, 0.0))
	_image_hp_bar_fill.draw_rect(to_canvas_item, Rect2(x - 11.0, y - 4.0, 33.0 * hp_ratio * _image_hp_bar_fill.get_width(), _image_hp_bar_fill.get_height()), false, hp_color)
	_army_res.get_image("hpbar_movementmark_{0}.png".format([str(movement) if movement > 0 else "e"])).draw(to_canvas_item, Vector2(x - 23.0, y - 7.0))
	if cards & (1<<3) != 0:
		if ai:
			render_ai_commander_medal(to_canvas_item, 1, x, y + 10.0, country_name, alliance)
		else:
			@warning_ignore("integer_division")
			_army_res.get_image("commander_level_{0}_s.png".format([level / 3 + 1])).draw(to_canvas_item, Vector2(x + 8.0, y - 8.0))
	elif level > 0:
		_army_res.get_image("unitlevelmark_{0}.png".format([level])).draw(to_canvas_item, Vector2(x + 8.0, y - 8.0))
	var card_pos := Vector2(x - 50.0, y - 20.0)
	for i in 3:
		if cards & (1<<i):
			_army_res.get_image("cardmark_{0}.png".format([i + 1])).draw(to_canvas_item, card_pos)
			card_pos.y -= 15.0


func render_ui_attack_army(to_canvas_item: RID, country_name: StringName, x: float, y: float, id: int, strength: int, max_strength: int, movement: int, cards: int, level: int, alliance: int, ai: bool) -> void:
	var army := _get_army_image(country_name, id, false)
	if army != null:
		army.draw_rect(to_canvas_item, Rect2(x, y, army.get_width(), army.get_height()), false)
	_image_hp_bar.draw(to_canvas_item, Vector2(x - 30.0, y - 12.0))
	var hp_ratio := strength as float / max_strength
	var hp_color := Color(minf(2 - 2 * hp_ratio, 1.0), minf(2 * hp_ratio, 1.0), maxf(hp_ratio - 0.5, 0.0))
	_image_hp_bar_fill.draw_rect(to_canvas_item, Rect2(x - 11.0, y - 4.0, 33.0 * hp_ratio * _image_hp_bar_fill.get_width(), _image_hp_bar_fill.get_height()), false, hp_color)
	_army_res.get_image("hpbar_movementmark_{0}.png".format([str(movement) if movement > 0 else "e"])).draw(to_canvas_item, Vector2(x - 23.0, y - 7.0))
	if cards & (1<<3) != 0:
		if ai:
			render_ai_commander_medal(to_canvas_item, 1, x, y + 10.0, country_name, alliance)
		else:
			@warning_ignore("integer_division")
			_army_res.get_image("commander_level_{0}_s.png".format([level / 3 + 1])).draw(to_canvas_item, Vector2(x + 8.0, y - 8.0))
	elif level > 0:
		_army_res.get_image("unitlevelmark_{0}.png".format([level])).draw(to_canvas_item, Vector2(x + 8.0, y - 8.0))
	var card_pos := Vector2(x + 36.0, y - 20.0)
	for i in 3:
		if cards & (1<<i):
			_army_res.get_image("cardmark_{0}.png".format([i + 1])).draw(to_canvas_item, card_pos)
			card_pos.y -= 15.0


func render_ai_commander_medal(to_canvas_item: RID, stack: int, x: float, y: float, country_name: StringName, common: int) -> void:
	y -= [10.0, 13.0, 15.0, 17.0][stack - 1]
	var medal := _army_res.get_image("medal_{0}.png".format([country_name]))
	if medal == null:
		medal = _army_res.get_image("medal_common_{0}.png".format([common]))
	if medal == null:
		medal = _army_res.get_image("medal_common_3.png".format([common]))
	medal.draw(to_canvas_item, Vector2(x + 8.0, y - 8.0))


func render_ui_army(to_canvas_item: RID, country_name: StringName, x: float, y: float, id: int, carrier: bool, strength: int, max_strength: int, movement: int, cards: int, level: int) -> void:
	var army := _get_army_image(country_name, id, carrier)
	if army != null:
		army.draw_rect(to_canvas_item, Rect2(x, y, -army.get_width(), army.get_height()), false)
	_image_hp_bar.draw(to_canvas_item, Vector2(x - 30.0, y - 12.0))
	var hp_ratio := strength as float / max_strength
	var hp_color := Color(minf(2 - 2 * hp_ratio, 1.0), minf(2 * hp_ratio, 1.0), maxf(hp_ratio - 0.5, 0.0))
	_image_hp_bar_fill.draw_rect(to_canvas_item, Rect2(x - 11.0, y - 4.0, 33.0 * hp_ratio * _image_hp_bar_fill.get_width(), _image_hp_bar_fill.get_height()), false, hp_color)
	_army_res.get_image("hpbar_movementmark_{0}.png".format([str(movement) if movement > 0 else "e"])).draw(to_canvas_item, Vector2(x - 23.0, y - 7.0))
	if cards & (1<<3) != 0:
		@warning_ignore("integer_division")
		_army_res.get_image("commander_level_{0}_s.png".format([level / 3 + 1])).draw(to_canvas_item, Vector2(x + 8.0, y - 8.0))
	elif level > 0:
		_army_res.get_image("unitlevelmark_{0}.png".format([level])).draw(to_canvas_item, Vector2(x + 8.0, y - 8.0))
	var card_pos := Vector2(x + 16.0, y - 20.0)
	for i in 3:
		if cards & (1<<i):
			_army_res.get_image("cardmark_{0}.png".format([i + 1])).draw(to_canvas_item, card_pos)
			card_pos.y -= 15.0


func render_army(to_canvas_item: RID, country_name: StringName, alliance: int, stack: int, x: float, y: float, id: int, color: Color, sea: int, dir: float) -> void:
	var army := _get_army_image(country_name, id, sea)
	if army != null:
		var unit_base: Texture2D
		match alliance:
			1:
				unit_base = _army_res.get_image("unitbase_blue_{0}.png".format([stack]))
			2:
				unit_base = _army_res.get_image("unitbase_green_{0}.png".format([stack]))
			3:
				unit_base = _army_res.get_image("unitbase_red_{0}.png".format([stack]))
			4:
				unit_base = _army_res.get_image("unitbase_gray_{0}.png".format([stack]))
		unit_base.draw(to_canvas_item, Vector2(x, y))
		var army_pos := Vector2(x, y - [10.0, 13.0, 15.0, 17.0][stack - 1])
		army.draw_rect(to_canvas_item, Rect2(army_pos.x, army_pos.y, dir * army.get_width(), army.get_height()), false, color)
		if sea != 0 and id <= 5:
			var mark_carriers: Texture2D
			match alliance:
				1:
					mark_carriers = _army_res.get_image(&"mark_carriers_blue.png")
				2:
					mark_carriers = _army_res.get_image(&"mark_carriers_green.png")
				3:
					mark_carriers = _army_res.get_image(&"mark_carriers_red.png")
				4:
					mark_carriers = _army_res.get_image(&"mark_carriers_gray.png")
			mark_carriers.draw(to_canvas_item, Vector2(x, y - 20.0))
			_army_res.get_image("mark_carriers_{0}.png".format([id + 1])).draw(to_canvas_item, Vector2(x, y - 20.0))


func _get_army_image(country_name: StringName, id: int, sea: int) -> Texture2D:
	if sea != 0 and id <= 5:
		return _army_res.get_image(&"transportship.png")
	var key: StringName
	var key_ne: StringName
	match id:
		0:
			key = "soldier_{0}.png".format([country_name])
			key_ne = &"soldier_ne.png"
		1:
			key = "panzer_{0}.png".format([country_name])
			key_ne = &"panzer_ne.png"
		2:
			key = "cannon_{0}.png".format([country_name])
			key_ne = &"cannon_ne.png"
		3:
			key = "rocketlauncher_{0}.png".format([country_name])
			key_ne = &"rocketlauncher_ne.png"
		4:
			key = "tank_{0}.png".format([country_name])
			key_ne = &"tank_ne.png"
		5:
			key = "heavytank_{0}.png".format([country_name])
			key_ne = &"heavytank_ne.png"
		6:
			key = "destroyer_{0}.png".format([country_name])
			key_ne = &"destroyer.png"
		7:
			key = "cruiser_{0}.png".format([country_name])
			key_ne = &"cruiser.png"
		8:
			key = "battleship_{0}.png".format([country_name])
			key_ne = &"battleship.png"
		9:
			key = "aircraftcarrier_{0}.png".format([country_name])
			key_ne = &"aircraftcarrier.png"
		_:
			return null
	var army := _army_res.get_image(key)
	if army == null:
		army = _army_res.get_image(key_ne)
	return army


func release() -> void:
	ecEffectManager.instance().remove_all()
	_army_res = null
	_image_hp_bar = null
	_image_hp_bar_fill = null
	arrow_green = null
	arrow_yellow = null
	arrow_blue = null
	arrow_red = null
	arrow_shadow = null
	_image_build_mark_airport = null
	_image_build_mark_port = null
	_cardtex_res = null
	card_d_research.clear()
	_battlebg_res = null
	_flag_res = null
	_eff_res = null
	_effect_cache.clear()


func get_flag_image(image_name: StringName) -> ecImageAttr:
	return _flag_res.get_image(image_name)


func get_battle_bg(bg_name: StringName) -> ecImageAttr:
	return _battlebg_res.get_image(bg_name)


func render_installation(to_canvas_item: RID, type: int, x: float, y: float)-> void:
	if type == 0:
		return
	var mark: Texture2D
	match type:
		1:
			mark = _army_res.get_image(&"buildmark_fortress.png")
		2:
			mark = _army_res.get_image(&"buildmark_wire.png")
		3:
			mark = _army_res.get_image(&"buildmark_aagun.png")
		4:
			mark = _army_res.get_image(&"buildmark_radar.png")
	mark.draw(to_canvas_item, Vector2(x, y))


func render_port(to_canvas_item: RID, x: float, y: float) -> void:
	_image_build_mark_port.draw(to_canvas_item, Vector2(x, y))


func render_construction(to_canvas_item: RID, type: int, level: int, x: float, y: float)-> void:
	match type:
		1:
			if level > 0:
				_army_res.get_image("buildmark_city_{0}.png".format([level])).draw(to_canvas_item, Vector2(x, y))
		2:
			if level > 0:
				_army_res.get_image("buildmark_factory_{0}.png".format([level])).draw(to_canvas_item, Vector2(x, y))
		3:
			_image_build_mark_airport.draw(to_canvas_item, Vector2(x, y))


func _render_army_movement_num(to_canvas_item: RID, x: float, y: float, movement: int) -> void:
	if movement <= 3:
		_army_res.get_image("hpbar_movementmark_{0}.png".format([str(movement) if movement > 0 else "e"])).draw(to_canvas_item, Vector2(x, y))


func render_army_level(to_canvas_item: RID, x: float, y: float, level: int) -> void:
	if level > 0:
		_army_res.get_image("unitlevelmark_{0}.png".format([level])).draw(to_canvas_item, Vector2(x, y))


func render_army_hp(to_canvas_item: RID, x: float, y: float, strength: int, max_strength: int) -> void:
	var hp_ratio := strength as float / max_strength
	var hp_color := Color(minf(2 - 2 * hp_ratio, 1.0), minf(2 * hp_ratio, 1.0), maxf(hp_ratio - 0.5, 0.0))
	_image_hp_bar_fill.draw_rect(to_canvas_item, Rect2(x, y, 33.0 * hp_ratio * _image_hp_bar_fill.get_width(), _image_hp_bar_fill.get_height()), false, hp_color)


func render_commander_medal(to_canvas_item: RID, stack: int, x: float, y: float, commander_level: int) -> void:
	@warning_ignore("integer_division")
	_army_res.get_image("commander_level_{0}_s.png".format([commander_level / 3 + 1])).draw(to_canvas_item, Vector2(x + 8.0, y - [10.0, 13.0, 15.0, 17.0][stack - 1] - 8.0))


func render_army_info(to_canvas_item: RID, stack: int, x: float, y: float, strength: int, max_strength: int, movement: int, cards: int, level: int) -> void:
	y -= [10.0, 13.0, 15.0, 17.0][stack - 1]
	_image_hp_bar.draw(to_canvas_item, Vector2(x - 30.0, y - 12.0))
	var hp_ratio := strength as float / max_strength
	var hp_color := Color(minf(2 - 2 * hp_ratio, 1.0), minf(2 * hp_ratio, 1.0), maxf(hp_ratio - 0.5, 0.0))
	_image_hp_bar_fill.draw_rect(to_canvas_item, Rect2(x - 11.0, y - 4.0, 33.0 * hp_ratio * _image_hp_bar_fill.get_width(), _image_hp_bar_fill.get_height()), false, hp_color)
	_army_res.get_image("hpbar_movementmark_{0}.png".format([str(movement) if movement > 0 else "e"])).draw(to_canvas_item, Vector2(x - 23.0, y - 7.0))
	if cards & (1<<3) == 0 and level > 0:
		_army_res.get_image("unitlevelmark_{0}.png".format([level])).draw(to_canvas_item, Vector2(x + 8.0, y - 8.0))
	var card_pos := Vector2(x + 26.0, y)
	for i in 3:
		if cards & (1<<i):
			_army_res.get_image("cardmark_{0}.png".format([i + 1])).draw(to_canvas_item, card_pos)
			card_pos.y -= 15.0
