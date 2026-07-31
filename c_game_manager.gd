extends Node

var _all_country: Array[CCountry]
var _belligerent_country: Array[CCountry]
var _dialogue: Array[DialogueDef]
var _current_country: int
var _current_dialogue: int
var current_round: int
var random_reward_medal: int
var game_mode: int
var _map: int
var _areas_enable: String
var _battle_file_name: String
var _save_file_name: String
var _player_country_name: Array[String]
var _conquest_player_country_id: String
var is_new_game: bool
var _local_game: bool
var _game_ended: bool
var _game_won: bool
var should_show_next_battle: bool
var campaign: int
var battle: int
var victory: int
var _great_victory: int
var campaign_reward_medal: int

func _init() -> void:
	_player_country_name.resize(4)


func _get_player_country_name(player_no: int) -> String:
	if player_no > 3:
		return ""
	return _player_country_name[player_no]


func _get_player_no(country_name: String) -> int:
	return _player_country_name.find(country_name)


func set_conquest_player_country_id(value: String) -> void:
	_conquest_player_country_id = value


func new_game(new_game_mode: int, map_index: int, new_campaign: int, new_battle: int) -> void:
	game_mode = new_game_mode
	if map_index >= 0:
		_map = map_index + 1
	campaign = new_campaign
	battle = new_battle
	victory = 100000
	_great_victory = 10
	if game_mode == 1:
		var battle_key_name = AppDelegate.get_battle_key_name(campaign, battle)
		var battle_def := CObjectDef.instance().get_battle_def(battle_key_name)
		if battle_def != null:
			victory = battle_def.victory
			_great_victory = battle_def.greatvictory
	_battle_file_name = AppDelegate.get_battle_file_name(game_mode, campaign, battle)
	_player_country_name.fill("")
	is_new_game = true


func load_game(save_file_name: String) -> void:
	var header := get_save_header(save_file_name)
	if header != null:
		game_mode = header.game_mode
		_map = header.map_id
		_areas_enable = header.areas_enable
		_player_country_name = header.player_country_name
		_battle_file_name = header.battle_file_name
		campaign = header.campaign
		battle = header.battle
		_save_file_name = save_file_name
	is_new_game = false


func get_save_header(save_file_name: String) -> SaveHeader:
	var path = EC2dAppDelegate.get_document_path(save_file_name)
	var file := ecFile.new()
	if not file.open(path, FileAccess.READ):
		return null
	return _get_save_header_from_file(file)


func _get_save_header_from_file(file: ecFile) -> SaveHeader:
	var header := SaveHeader.new()
	file.read(header._mem, 0xBC)
	return header


func retry_game() -> void:
	is_new_game = true


# TODO: save_game


func is_last_battle() -> bool:
	return game_mode == 1 and battle == AppDelegate.get_num_battles(campaign) - 1


# TODO: _get_num_countries


# TODO: get_country_by_index


# TODO: get_player_country


# TODO: _get_num_dialogue


# TODO: _get_dialogue_by_index


# TODO: _save_battle


# TODO: get_cur_dialogue


# TODO: next_dialogue


# TODO: check_and_set_result


func battle_victory() -> void:
	if game_mode != 1:
		return
	var star := get_num_victory_stars()
	if star == 0:
		return
	g_Commander.set_battle_played(campaign, battle)
	var old_star = g_Commander.get_num_battle_stars(campaign, battle)
	if old_star <= 0:
		if star == 5:
			campaign_reward_medal = 50
		elif star == 4:
			campaign_reward_medal = 25
		elif star == 3:
			campaign_reward_medal = 15
		elif star == 2:
			campaign_reward_medal = 5
		else:
			campaign_reward_medal = 0
		g_Commander.medal += campaign_reward_medal
	if old_star < star:
		g_Commander.set_num_battle_stars(campaign, battle, star)


func get_num_victory_stars() -> int:
	if not _game_won:
		return 0
	var turn := current_round + 1
	if turn <= _great_victory:
		return 5
	elif turn >= victory:
		return 1
	@warning_ignore("integer_division")
	var star := 4 * (victory - turn) / (victory - _great_victory) + 1
	if star < 2:
		star = 2
	return star


# TODO: _get_new_defeated_country


# TODO: is_manipulate


# TODO: _turn_end


# TODO: end_turn


# TODO: _next


# TODO: _game_update


func init_battle() -> void:
	if is_new_game:
		_load_battle(_battle_file_name)
		_current_dialogue = 0
		current_round = 0
		random_reward_medal = 0
		if game_mode != 4:
			_move_player_country_to_front()
			var player_country := _get_player_country()
			if player_country != null:
				_set_player_country_name(0, player_country.name)
				if game_mode == 2:
					for i in _all_country:
						if i.alliance == player_country.alliance:
							i.tax_factor = 1.0
		else:
			pass # TODO: initialze multiplayer game
		_init_camera_pos()
	else:
		_real_load_game(_save_file_name)
	_game_ended = false
	campaign_reward_medal = 0
	_local_game = game_mode != 4
	g_Scene.all_areas_encirclement()
	var ai_area_with_army_count := 0
	var sea_area_count := 0
	for i in g_Scene.get_num_areas():
		var area: CArea = g_Scene.get_area(i)
		if area != null:
			if area.country != null and area.country.ai and area.get_num_armies() > 0:
				ai_area_with_army_count += 1
			if area.sea != 0:
				sea_area_count += 1
	CActionAI.instance().ai_area_with_army_count = ai_area_with_army_count
	CActionAssist.instance().sea_area_count = sea_area_count
	CActionAI.instance().ai_progress_percentage = 1


func _load_battle(file_name: String) -> void:
	_clear_battle()
	var res_battle: SaveHeader = load(EC2dAppDelegate.get_asset_path(file_name, ""))
	g_Scene.init(res_battle.areas_enable, res_battle.map)
	for i in res_battle.country:
		var country := CCountry.new()
		country.init(i.id, i.name)
		country.color = i.color
		country.alliance = i.alliance
		country.tax_factor = i.tax_factor
		country.ai = i.ai
		if game_mode == 4:
			# TODO: set up country for multiplayer
			pass
		elif game_mode == 2:
			country.ai = country.id == _conquest_player_country_id
		country.set_commander(i.commander)
		country.money = i.money
		country.tech_level = clampi(i.techlevel, 1, 5)
		country.industry = i.industry
		_all_country.append(country)
		if country.alliance != 4:
			_belligerent_country.append(country)
	for i in res_battle.area:
		var id := i.id
		var area: CArea = g_Scene.get_area(id)
		if area != null:
			var country := _find_country(i.country)
			g_Scene.set_area_country(id, country)
			if country != null:
				country.add_area(id)
			var construction = i.construction
			var level = i.level
			if area.sea == 0:
				area.set_construction(construction, level)
			area.installation = i.installation
			for j in i.army:
				if country != null:
					var army_def := CObjectDef.instance().get_army_def(j.type, country.name)
					var army := CArmy.new()
					army.init(army_def)
					army.country = country
					army.cards = j.cards
					army.level = j.level
					if area.sea != 0 and army.movement > 1:
						army.movement = 1
					area.add_army(army, true)
					if army.cards & (1 << 3) != 0:
						country.commander_alive = true
					army.reset_max_strength(false)
	_dialogue = res_battle.dialogue.duplicate()
	_current_country = 0


func _clear_battle() -> void:
	_all_country.clear()
	_belligerent_country.clear()
	_dialogue.clear()


func _find_country(id: StringName) -> CCountry:
	for i in _all_country:
		if i.id == id:
			return i
	return null


func _move_player_country_to_front() -> void:
	var c := _get_player_country()
	if c != null:
		_all_country.erase(c)
		_all_country.push_front(c)


func _get_player_country() -> CCountry:
	for c in _all_country:
		if not c.ai:
			return c
	return null


func _set_player_country_name(player_no: int, value: String) -> void:
	if player_no <= 3:
		_player_country_name[player_no] = value


func _init_camera_pos() -> void:
	var country := get_cur_country()
	if country != null:
		var area := country.get_highest_value_area()
		if area >= 0:
			g_Scene.set_camera_to_area(area)


func get_cur_country() -> CCountry:
	if _current_country < 0 or _current_country >= _all_country.size():
		return null
	return _all_country[_current_country]


func _real_load_game(file_name: String) -> void:
	_clear_battle()
	g_Scene.init(_areas_enable, _map)
	var path = EC2dAppDelegate.get_document_path(file_name)
	var file := ecFile.new()
	if file.open(path, FileAccess.READ):
		var save := _get_save_header_from_file(file)
		var buf_country: PackedByteArray
		file.read(buf_country, 276 * save.country_count)
		var buf_area: PackedByteArray
		file.read(buf_country, 200 * save.area_count)
		file.close()
		for i in save.country_count:
			var info := SaveCountryInfo.new()
			info._mem = buf_country
			info._offset = 276 * i
			var country := CCountry.new()
			country.init(info.id, info.name)
			country.load_country(info)
			_all_country.append(country)
			if country.alliance != 4:
				_belligerent_country.append(country)
		for i in save.area_count:
			var info := SaveAreaInfo.new()
			info._mem = buf_area
			info._offset = 200 * i
			var area: CArea = g_Scene.get_area(info.id)
			area.country = _all_country[info.country_index]
			area.load_area(info)
			_all_country[info.country_index].add_area(info.id)
		campaign = save.campaign
		_current_country = save.current_country
		_current_dialogue = save.current_dialogue
		battle = save.battle
		_great_victory = save.great_victory
		victory = save.victory
		current_round = save.current_round
		random_reward_medal = save.random_reward_medal
		g_Scene.camera.set_pos(save.camera_x, save.camera_y, false)
		g_Scene.camera.scale = Vector2(save.camera_scale, save.camera_scale)


func get_local_player_country() -> CCountry:
	return null


func turn_begin() -> void:
	pass
