extends Node

const _ecTextureResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_texture_res_assets.gd")
const _ecEffectResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_effect_res_assets.gd")
const _ecImageAttr = preload("res://app/src/main/cpp/ec_image_attr.gd")
const _ecTextureRes = preload("res://app/src/main/cpp/ec_texture_res.gd")
const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")

var _army_res: _ecTextureResAssets
var _cardtex_res: _ecTextureResAssets
var _battlebg_res: _ecTextureResAssets
var _flag_res: _ecTextureResAssets
var _eff_res: _ecTextureResAssets
var _effect_cache: Array[_ecEffectResAssets]
var card_d_research: Dictionary[int, Texture2D]

func load_res() -> void:
	var res: _ecTextureRes
	_army_res = load("res://app/src/main/cpp/scene_system_resource/game_res/army.tres")
	_cardtex_res = load("res://app/src/main/cpp/scene_system_resource/game_res/cardtex.tres")
	res = _cardtex_res.get_res()
	var regex_card_d_research := RegEx.create_from_string("card_d_research_([0-9]+).png")
	for i in res.get_keys():
		var regex_match: RegExMatch
		regex_match = regex_card_d_research.search(i)
		if regex_match.get_group_count() > 0:
			card_d_research[regex_match.get_string(1).to_int()] = _ecImageTexture.from_ec_image_attr(res.get_image(i))
	_battlebg_res = load("res://app/src/main/cpp/scene_system_resource/game_res/battlebg.tres")
	_flag_res = load("res://app/src/main/cpp/scene_system_resource/game_res/flag.tres")
	_eff_res = load("res://app/src/main/cpp/scene_system_resource/game_res/eff.tres")
	_effect_cache = [
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_airstrike.tres"),
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_exp.tres"),
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_fortfire.tres"),
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_gunfire.tres"),
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_mgunfire.tres"),
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_nuclearbomb.tres"),
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_parachute.tres"),
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_shipfire.tres"),
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_strike1.tres"),
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_strike2.tres"),
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_strike3.tres"),
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_strike4.tres"),
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_strike5.tres"),
		load("res://app/src/main/cpp/scene_system_resource/game_res/effect_tankfire.tres")
	]


func release() -> void:
	_army_res = null
	_cardtex_res = null
	_battlebg_res = null
	_flag_res = null
	_eff_res = null
	_effect_cache.clear()


func render_ai_commander_medal(stack: int, x: float, y: float, commander: StringName, common: int) -> void:
	pass


func render_commander_medal(stack: int, x: float, y: float, commander_level: int) -> void:
	pass


func render_ui_attack_army(country: String, x: float, y: float, id: int, durability: int, max_durability: int, movement: int, cards: int, level: int, alliance: int, ai: bool) -> void:
	pass


func render_ui_defend_army(country: String, x: float, y: float, id: int, durability: int, max_durability: int, movement: int, cards: int, level: int, alliance: int, ai: bool) -> void:
	pass


func render_ui_army(country: String, x: float, y: float, id: int, carrier: bool, durability: int, max_durability: int, movement: int, cards: int, level: int) -> void:
	pass


func get_flag_image(image_name: StringName) -> _ecImageAttr:
	return null
