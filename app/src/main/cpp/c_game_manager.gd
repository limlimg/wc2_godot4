extends Node

const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _CObjectDef = preload("res://app/src/main/cpp/c_object_def.gd")
const _ecFile = preload("res://app/src/main/cpp/ec_file.gd")
const _SaveHeader = preload("res://app/src/main/cpp/save_header.gd")

var _current_turn_num_minus_1: int
var _game_mode: int
var _map_id: int
var _areas_enable: String
var _battle_file_name: String
var _save_file_name: String
var _player_country_name: Array[String]
var _conquest_player_country_id: String
var _is_new_game: bool
var _is_last_game_won: bool
var should_show_next_battle: bool
var _campaign: int
var _battle: int
var _victory_turn: int
var _great_victory_turn: int
var _campaign_reward_medal: int

func _init() -> void:
	_player_country_name.resize(4)


func _get_player_country_name(player_no: int) -> String:
	if player_no > 3:
		return ""
	return _player_country_name[player_no]


func _set_player_country_name(player_no: int, value: String) -> void:
	if player_no <= 3:
		_player_country_name[player_no] = value


func _get_player_no(country_name: String) -> int:
	return _player_country_name.find(country_name)


func set_conquest_player_country_id(value: String) -> void:
	_conquest_player_country_id = value


func new_game(game_mode: int, map_id_minus_1: int, campaign: int, battle: int) -> void:
	_game_mode = game_mode
	if map_id_minus_1 >= 0:
		_map_id = map_id_minus_1 + 1
	_campaign = campaign
	_battle = battle
	_victory_turn = 100000
	_great_victory_turn = 10
	if game_mode == 1:
		var battle_key_name := _native.get_battle_key_name(campaign, battle)
		var battle_def := _CObjectDef.instance().get_battle_def(battle_key_name)
		if battle_def != null:
			_victory_turn = battle_def.victory
			_great_victory_turn = battle_def.greatvictory
	_battle_file_name = _native.get_battle_file_name(game_mode, campaign, battle)
	_player_country_name.fill("")
	_is_new_game = true


func load_game(save_file_name: String) -> void:
	var header := get_save_header(save_file_name)
	if header != null:
		_game_mode = header.game_mode
		_map_id = header.map_id
		_areas_enable = header.areas_enable
		_player_country_name = header.player_country_name
		_battle_file_name = header.battle_file_name
		_campaign = header.campaign
		_battle = header.battle
		_save_file_name = save_file_name
	_is_new_game = false


func get_save_header(save_file_name: String) -> _SaveHeader:
	var path := _native.get_document_path(save_file_name)
	var file := _ecFile.new()
	if not file.open(path, FileAccess.READ):
		return null
	var buffer: PackedByteArray
	file.read(buffer, 0xBC)
	var header := _SaveHeader.new()
	header.game_mode = buffer.decode_s32(8)
	header.map_id = buffer.decode_s32(16)
	header.areas_enable = buffer.slice(20, buffer.find(0, 20)).get_string_from_ascii()
	header.player_country_name[0] = buffer.slice(52, buffer.find(0, 52)).get_string_from_ascii()
	header.player_country_name[1] = buffer.slice(60, buffer.find(0, 60)).get_string_from_ascii()
	header.player_country_name[2] = buffer.slice(68, buffer.find(0, 68)).get_string_from_ascii()
	header.player_country_name[3] = buffer.slice(76, buffer.find(0, 76)).get_string_from_ascii()
	header.battle_file_name = buffer.slice(84, buffer.find(0, 84)).get_string_from_ascii()
	header.camera_x = buffer.decode_float(116)
	header.camera_y = buffer.decode_float(120)
	header.camera_scale = buffer.decode_float(124)
	header.current_country_index = buffer.decode_u32(128)
	header.current_dialogue_index = buffer.decode_u32(132)
	header.country_count = buffer.decode_u32(136)
	header.area_count = buffer.decode_u32(140)
	header.current_turn_num_minus_1 = buffer.decode_u32(144)
	header.random_reward_medal = buffer.decode_u32(148)
	header.save_time_year = buffer.decode_u32(152)
	header.save_time_month = buffer.decode_u32(156)
	header.save_time_day = buffer.decode_u32(160)
	header.save_time_hour = buffer.decode_u32(164)
	header.save_time_min = buffer.decode_u32(168)
	header.campaign = buffer.decode_s32(172)
	header.battle = buffer.decode_s32(176)
	header.victory_turn = buffer.decode_s32(180)
	header.great_victory_turn = buffer.decode_s32(184)
	return header


func retry_game() -> void:
	_is_new_game = true


# TODO: save_game


# TODO: _clear_battle


func is_last_battle() -> bool:
	return _game_mode == 1 and _battle == _native.get_num_battles(_campaign) - 1


# TODO: _get_num_countries


# TODO: get_country_by_index


# TODO: find_country


# TODO: get_cur_country


# TODO: _init_camera_pos


# TODO: get_player_country


# TODO: get_local_player_country


# TODO: _get_num_dialogue


# TODO: _get_dialogue_by_index


# TODO: _save_battle


# TODO: get_cur_dialogue


# TODO: next_dialogue


# TODO: check_and_set_result


func battle_victory() -> void:
	if _game_mode != 1:
		return
	var star := get_num_victory_stars()
	if star == 0:
		return
	g_Commander.set_battle_played(_campaign, _battle)
	var old_star := g_Commander.get_num_battle_stars(_campaign, _battle)
	if old_star <= 0:
		if star == 5:
			_campaign_reward_medal = 50
		elif star == 4:
			_campaign_reward_medal = 25
		elif star == 3:
			_campaign_reward_medal = 15
		elif star == 2:
			_campaign_reward_medal = 5
		else:
			_campaign_reward_medal = 0
		g_Commander.medal += _campaign_reward_medal
	if old_star < star:
		g_Commander.set_num_battle_stars(_campaign, _battle, star)


func get_num_victory_stars() -> int:
	if not _is_last_game_won:
		return 0
	var turn := _current_turn_num_minus_1 + 1
	if turn <= _great_victory_turn:
		return 5
	elif turn >= _victory_turn:
		return 1
	@warning_ignore("integer_division")
	var star := 4 * (_victory_turn - turn) / (_victory_turn - _great_victory_turn) + 1
	if star < 2:
		star = 2
	return star


# TODO: _get_new_defeated_country


# TODO: is_manipulate


# TODO: turn_begin


# TODO: _turn_end


# TODO: end_turn


# TODO: _next


# TODO: _game_update


# TODO: _move_player_country_to_front


# TODO: _real_load_game


# TODO: _load_battle


# TODO: init_battle
