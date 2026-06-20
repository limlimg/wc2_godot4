extends Node

const _ecTextureResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_texture_res_assets.gd")
const _ecEffectResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_effect_res_assets.gd")

var _army_res: _ecTextureResAssets
var _cardtex_res: _ecTextureResAssets
var _battlebg_res: _ecTextureResAssets
var _flag_res: _ecTextureResAssets
var _eff_res: _ecTextureResAssets
var _effect_cache: Array[_ecEffectResAssets]

func load_res() -> void:
	_army_res = load("res://app/src/main/cpp/scene_system_resource/game_res/army.tres")
	_cardtex_res = load("res://app/src/main/cpp/scene_system_resource/game_res/cardtex.tres")
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
