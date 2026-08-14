class_name CCountry

var alliance: int
var defeated: int
var area_list: PackedInt32Array
var _capital_list: PackedInt32Array
var money: int
var industry: int
var tax_factor: float
var id: StringName
var name: StringName
var color: Color
var ai: bool
var conquested: bool
var _action := CountryAction.new()
var _action_time: float
var _action_delay_time: float
var _waiting_camera: bool
var tech_level: int
var research_round: int
var _card_rounds: PackedInt32Array
var _card_target_list: PackedInt32Array
var _card_target_index: int
var _destroy: PackedInt32Array
var commander_def: CommanderDef
var commander_round: int
var commander_alive: bool
var _war_medal: PackedInt32Array
var borrowed_loan: bool

func init(init_id: StringName, init_name: StringName) -> void:
	area_list.clear()
	_capital_list.clear()
	id = init_id
	name = init_name
	commander_round = 0
	commander_alive = false
	commander_def = null
	money = 0
	industry = 0
	research_round = 0
	defeated = 0
	conquested = false
	borrowed_loan = false
	tech_level = 1
	ai = true
	color = Color.WHITE
	_card_rounds.resize(28)
	for i in 28:
		_card_rounds[i] = CObjectDef.instance().get_card_def(i).round
	_war_medal.resize(6)
	_war_medal.fill(0)
	_destroy.resize(10)
	_destroy.fill(0)
	tax_factor = 1.0


func remove_area(area_id: int) -> void:
	area_list.erase(area_id)
	if g_Scene.get_area(area_id).type == 1:
		_capital_list.erase(area_id)


func add_area(area_id: int) -> void:
	if _find_area(area_id):
		return
	area_list.append(area_id)
	if g_Scene.get_area(area_id).type == 1:
		_capital_list.append(area_id)


func _find_area(area_id: int) -> bool:
	return area_list.has(area_id)


func get_highest_value_area() -> int:
	var max_id := -1
	var max_value := 0
	for i in area_list:
		var area = g_Scene.get_area(i)
		if area.has_army_card(3):
			return i
		var value := CActionAssist.calc_area_value(area)
		if value > max_value:
			max_value = value
			max_id = i
	return max_id


func _get_first_capital() -> int:
	if _capital_list.is_empty():
		return -1
	return _capital_list[0]


func is_conquested() -> bool:
	for i in area_list:
		var area = g_Scene.get_area(i)
		if not area.sea:
			return false
		if defeated == 1 and area.get_num_armies() > 0:
			return false
	return true


func _find_adjacent_area_id(area_id: int, has_army: bool) -> int:
	for i in g_Scene.get_num_adjacent_areas(area_id):
		var area = g_Scene.get_adjacent_area(area_id, i)
		if area.country == self and (not has_army or area.get_num_armies() > 0):
			return area.id
	return -1


func _find_adjacent_land_area_id(area_id: int, has_army: bool) -> int:
	for i in g_Scene.get_num_adjacent_areas(area_id):
		var area = g_Scene.get_adjacent_area(area_id, i)
		if area.country == self and area.sea == 0 and (not has_army or area.get_num_armies() > 0):
			return area.id
	return -1


func get_num_airport() -> int:
	var s := 0
	for i in area_list:
		if g_Scene.get_area(i).construction == 3:
			s += 1
	return s


func get_min_dst_to_airport(from_id: int) -> float:
	var d := INF
	var from_area := g_Scene.get_area(from_id)
	for i in area_list:
		var to_area := g_Scene.get_area(i)
		if to_area.construction == 3:
			d = min(d, from_area.army_pos.distance_squared_to(to_area.army_pos))
	return sqrt(d)


func _gen_card_target_list() -> void:
	# probably used for aoe cards in ew3
	pass


func _get_cur_card_target() -> int:
	if _card_target_index >= _card_target_list.size():
		return -1
	return _card_target_list[_card_target_index]


func _next_card_target() -> void:
	if _card_target_index < _card_target_list.size():
		_card_target_index += 1


func turn_end() -> void:
	for i in area_list:
		g_Scene.get_area(i).turn_end()
	if not commander_alive and commander_round > 0:
		commander_round -= 1
	for i in _card_rounds.size():
		if _card_rounds[i] > 0:
			_card_rounds[i] -= 1


func action(new_action: CountryAction) -> void:
	_action = new_action.duplicate()
	var action_type := new_action.type
	if action_type <= 0 or action_type > 6:
		return
	if action_type == 2:
		g_Scene.get_area(_action.target_area).set_army_active(_action.army_index, false)
		_finish_action()
	elif action_type == 6:
			g_Scene.move_camera_to_area(_action.target_area)
			_action_delay_time = 0.0
			_waiting_camera = true
	elif action_type == 1 or action_type == 3 or action_type == 4 or action_type == 5:
			if action_type == 3:
				g_Scene.flashing_red_area_id_1 = _action.start_area
				g_Scene.flashing_red_area_id_2 = _action.target_area
			if not is_local_player():
				if action_type == 4 or action_type == 5:
					g_Scene.move_camera_to_area(_action.target_area)
				else:
					g_Scene.move_camera_between_area(_action.start_area, _action.target_area)
				_action_delay_time = 0.0
				_waiting_camera = true
			else:
				_do_action()


func update(delta: float) -> void:
	if _waiting_camera:
		if _action_delay_time <= 0.0:
			if g_Scene.is_moving():
				return
		else:
			_action_time += delta
			if g_Scene.is_moving() or _action_time < _action_delay_time:
				return
		_waiting_camera = false
		_do_action()
	else:
		_action_time += delta
		var action_type := _action.type
		if action_type == 1 and g_Scene.get_area(_action.target_area).army_moving_in:
			return
		if action_type == 1 or action_type == 3 or action_type == 4 or action_type == 5:
			if _action_time <= 0.6:
				return
		_finish_action()


func _do_action() -> void:
	match _action.type:
		1:
			var start_area := g_Scene.get_area(_action.start_area)
			var army_index := _action.army_index
			if army_index > 0:
				start_area.move_army_to_front(army_index, false)
				army_index = 0
			var target_area := g_Scene.get_area(_action.target_area)
			start_area.move_army_to(target_area)
			if target_area != null and target_area.sea != 0:
				g_SoundRes.play_char_se(SND_EFFECT.SHIP_WAV)
			else:
				g_SoundRes.play_char_se(SND_EFFECT.MOVE_WAV)
		3:
			var start_area := g_Scene.get_area(_action.start_area)
			var army_index := _action.army_index
			if army_index > 0:
				start_area.move_army_to_front(army_index, false)
				army_index = 0
			var army := start_area.get_army(0)
			if army.def.id == 9:
				g_Scene.aircraft_carrier_bomb(_action.start_area, _action.target_area)
			else:
				var target_area := g_Scene.get_area(_action.target_area)
				var start_x := start_area.army_pos.x
				var target_x := target_area.army_pos.x
				if start_x < target_x:
					start_area.set_army_dir(0, 1.0)
					target_area.set_army_dir(0, -1.0)
				elif start_x > target_x:
					start_area.set_army_dir(0, -1.0)
					target_area.set_army_dir(0, 1.0)
				var animated := g_GameSettings.battle_animation\
					and ((start_area.country != null and not start_area.country.ai)
						or (target_area.country != null and not target_area.country.ai))
				CStateManager.instance().get_state_ptr(EState.GAME).start_battle(_action.start_area, _action.target_area, animated)
		4:
			var army_index := _action.army_index
			if army_index > 0:
				g_Scene.get_area(_action.target_area).move_army_to_front(army_index, false)
		5:
			var card_id := _action.card_id
			match card_id:
				CARD_ID.AIR_STRIKE_CARD:
					g_Scene.bomb_area(_action.target_area, 1)
				CARD_ID.BOMBER_CARD:
					g_Scene.bomb_area(_action.target_area, 2)
				CARD_ID.AIRBORNE_FORCE_CARD:
					g_Scene.airborne(_action.target_area)
				CARD_ID.NUCLEAR_BOMB_CARD:
					g_Scene.bomb_area(_action.target_area, 3)
				_:
					var card := CObjectDef.instance().get_card_def(card_id)
					if card_id >= CARD_ID.CARRIER_CARD and card_id <= CARD_ID.COMMANDER_CARD:
						use_card(card, _action.target_area, _action.army_index)
					else:
						use_card(card, _action.target_area, 0)
		6:
			_finish_action()


func _finish_action() -> void:
	if _action.type == 3:
		g_Scene.flashing_red_area_id_1 = -1
		g_Scene.flashing_red_area_id_2 = -1
	_action.type = 0


func is_action_finished() -> bool:
	return _action.type == 0


func save_country(info: SaveCountryInfo) -> void:
	info.research_round = research_round
	info.ai = ai
	info.money = money
	info.industry = industry
	info.techlevel = tech_level
	info.card_rounds = _card_rounds
	info.id = id
	info.name = name
	info.tax_factor = tax_factor
	info.color = color
	info.alliance = alliance
	info.defeated = defeated
	info.destroy = _destroy
	if commander_def != null:
		info.commander = commander_def.name
	info.commander_alive = commander_alive
	info.war_medal = _war_medal
	info.commander_round = commander_round
	info.borrowed_loan = borrowed_loan
	info.conquested = conquested


func add_destroy(army_id: int) -> void:
	if army_id <= 9:
		_destroy[army_id] += 1


func load_country(info: SaveCountryInfo) -> void:
	money = info.money
	industry = info.industry
	tech_level = info.techlevel
	research_round = info.research_round
	ai = info.ai
	_card_rounds = info.card_rounds
	id = info.id
	name = info.name
	tax_factor = info.tax_factor
	defeated = info.defeated
	color = info.color
	alliance = info.alliance
	_destroy = info.destroy
	set_commander(info.commander)
	commander_alive = info.commander_alive
	_war_medal = info.war_medal
	commander_round = info.commander_round
	borrowed_loan = info.borrowed_loan
	conquested = info.conquested


func set_commander(value: String) -> void:
	if ai:
		commander_def = CObjectDef.instance().get_commander_def(value)
		if commander_def != null:
			_war_medal[WARMEDAL_ID.INFANTRY_MEDAL] = commander_def.infantry
			_war_medal[WARMEDAL_ID.AIR_FORCE_MEDAL] = commander_def.airforce
			_war_medal[WARMEDAL_ID.ARTILLERY_MEDAL] = commander_def.artillery
			_war_medal[WARMEDAL_ID.ARMOUR_MEDAL] = commander_def.armour
			_war_medal[WARMEDAL_ID.NAVY_MEDAL] = commander_def.navy
			_war_medal[WARMEDAL_ID.COMMERCE_MEDAL] = commander_def.honour
	# TODO: multiplayer
	else:
		_war_medal[WARMEDAL_ID.INFANTRY_MEDAL] = g_Commander.get_war_medal_level(WARMEDAL_ID.INFANTRY_MEDAL)
		_war_medal[WARMEDAL_ID.AIR_FORCE_MEDAL] = g_Commander.get_war_medal_level(WARMEDAL_ID.AIR_FORCE_MEDAL)
		_war_medal[WARMEDAL_ID.ARTILLERY_MEDAL] = g_Commander.get_war_medal_level(WARMEDAL_ID.ARTILLERY_MEDAL)
		_war_medal[WARMEDAL_ID.ARMOUR_MEDAL] = g_Commander.get_war_medal_level(WARMEDAL_ID.ARMOUR_MEDAL)
		_war_medal[WARMEDAL_ID.NAVY_MEDAL] = g_Commander.get_war_medal_level(WARMEDAL_ID.NAVY_MEDAL)
		_war_medal[WARMEDAL_ID.COMMERCE_MEDAL] = g_Commander.get_war_medal_level(WARMEDAL_ID.COMMERCE_MEDAL)


func get_commander_level() -> int:
	if ai:
		if commander_def != null:
			return commander_def.rank
		else:
			return 8
	# TODO: multiplayer
	else:
		return g_Commander.rank


func commander_die() -> void:
	commander_alive = false
	var commander_name
	if ai:
		commander_round = 5
		commander_name = get_commander_name()
	else:
		commander_round = AppDelegate.get_commander_ability(get_commander_level())[5]
		commander_name = &"Player"
	if g_GameManager.game_mode != 4:
		var dlg := "commander retreat {0}".format([randi_range(1, 5)])
		CStateManager.instance().get_state_ptr(EState.GAME).show_dialogue(dlg, commander_name, false)


func get_commander_name() -> StringName:
	if commander_def == null:
		return &""
	return commander_def.name


func use_card(card: CardDef, area_id: int, army_index: int) -> bool:
	if not is_card_unlock(card):
		return false
	var card_price := get_card_price(card)
	if money < card_price:
		return false
	var card_industry := get_card_industry(card)
	if industry < card_industry:
		return false
	var area: CArea
	if area_id >= 0:
		area = g_Scene.get_area(area_id)
	var type := card.type
	var card_id := card.id
	if type <= 1:
		if not check_card_target_area(card, area_id):
			return false
		var army: CArmy
		match card_id:
			CARD_ID.INFANTRY_CARD:
				army = area.draft_army(0)
			CARD_ID.ARMOUR_CARD:
				army = area.draft_army(1)
			CARD_ID.ARTILLERY_CARD:
				army = area.draft_army(2)
			CARD_ID.ROCKET_CARD:
				army = area.draft_army(3)
			CARD_ID.TANK_CARD:
				army = area.draft_army(4)
			CARD_ID.HEAVY_TANK_CARD:
				army = area.draft_army(5)
			CARD_ID.DESTROYER_CARD:
				army = area.draft_army(6)
			CARD_ID.CRUISER_CARD:
				army = area.draft_army(7)
			CARD_ID.BATTLE_SHIP_CARD:
				army = area.draft_army(8)
			CARD_ID.AIRCRAFT_CARRIER_CARD:
				army = area.draft_army(9)
		if army != null:
			var level := get_war_medal_level(WARMEDAL_ID.NAVY_MEDAL)
			var army_id := army.def.id
			if level > 0:
				if army_id <= 5:
					army.cards |= 1<<2
				if level > 1:
					if army_id >= 6 and army_id <= 7:
						army.upgrade()
					if level > 2:
						if army_id >= 8 and army_id <= 9:
							army.upgrade()
			if army_id == 0:
				level = get_war_medal_level(WARMEDAL_ID.INFANTRY_MEDAL)
				if level > 0:
					army.upgrade()
					if level > 1:
						army.upgrade()
						if level > 2:
							army.cards |= (1<<1)|(1<<0) 
			level = get_war_medal_level(WARMEDAL_ID.ARTILLERY_MEDAL)
			if level > 0:
				if army_id == 2:
					army.upgrade()
					if level > 1:
						if army_id == 3:
							army.upgrade()
							if level > 2:
								if army_id >= 2 and army_id <= 3:
									army.cards |= 1<<1
			level = get_war_medal_level(WARMEDAL_ID.ARMOUR_MEDAL)
			if level > 0:
				if army_id == 1:
					army.upgrade()
				if level > 1:
					if army_id == 4:
						army.upgrade()
					if level > 2:
						if army_id == 5:
							army.upgrade()
		money -= card_price
		industry -= card_industry
		return true
	elif type == 2:
		if get_card_rounds(card.id) > 0:
			return false
		if not check_card_target_area(card, area_id):
			return false
		if card_id == CARD_ID.AIRBORNE_FORCE_CARD:
			var target_country := area.country
			if target_country != self:
				if target_country != null:
					target_country.remove_area(area_id)
				add_area(area_id)
				area.country = self
				if target_country != null and target_country.is_conquested():
					target_country.be_conquested_by(self)
			area.draft_army(0)
			money -= card_price
			industry -= card_industry
			_card_rounds[card.id] = card.round
			return true
		elif card_id == CARD_ID.AIR_STRIKE_CARD\
			or card_id == CARD_ID.BOMBER_CARD\
			or card_id == CARD_ID.NUCLEAR_BOMB_CARD:
			money -= card_price
			industry -= card_industry
			if get_war_medal_level(WARMEDAL_ID.AIR_FORCE_MEDAL) > 2:
				_card_rounds[card.id] = 0
			else:
				_card_rounds[card.id] = card.round
			return true
		else:
			return false
	elif type == 3:
		if not check_card_target_area(card, area_id):
			return false
		match card_id:
			CARD_ID.CITY_CARD:
				area.construct(1)
			CARD_ID.INDUSTRY_CARD:
				area.construct(2)
			CARD_ID.AIRPORT_CARD:
				area.construct(3)
			CARD_ID.LAND_FORT_CARD:
				area.installation = 1
			CARD_ID.ENTRENCHMENT_CARD:
				area.installation = 2
			CARD_ID.ANTIAIRCRAFT_CARD:
				area.installation = 3
			CARD_ID.RADAR_CARD:
				area.installation = 4
		money -= card_price
		industry -= card_industry
		g_SoundRes.play_char_se(SND_EFFECT.BUFF_WAV)
		return true
	elif type == 4:
		if card_id == CARD_ID.RESEARCH_CARD:
			if tech_level > 4 or research_round != 0:
				return false
			research_round = 3
			money -= card_price
			industry -= card_industry
			g_SoundRes.play_char_se(SND_EFFECT.LV_UP_WAV)
			return true
		elif card_id >= CARD_ID.CARRIER_CARD and card_id <= CARD_ID.DEFEND_ART_CARD:
			if not check_card_target_army(card, area_id, army_index):
				return false
			match card_id:
				CARD_ID.CARRIER_CARD:
					area.add_army_card(army_index, 2)
				CARD_ID.ASSAULT_ART_CARD:
					area.add_army_card(army_index, 0)
				CARD_ID.DEFEND_ART_CARD:
					area.add_army_card(army_index, 1)
			money -= card_price
			industry -= card_industry
			g_SoundRes.play_char_se(SND_EFFECT.BUFF_WAV)
			return true
		elif card_id == CARD_ID.COMMANDER_CARD:
			if not can_use_commander() or not check_card_target_army(card, area_id, army_index):
				return false
			commander_alive = true
			area.add_army_card(army_index, 3)
			var army := area.get_army(army_index)
			if army != null:
				army.add_strength(AppDelegate.get_commander_ability(get_commander_level())[3])
				army.reset_max_strength(false)
			money -= card_price
			industry -= card_industry
			g_SoundRes.play_char_se(SND_EFFECT.BUFF_WAV)
			if ai and g_GameManager.game_mode != 4:
				var commander := get_commander_name()
				if not commander.is_empty():
					var dlg := "commander return {0}".format([randi_range(1, 5)])
					CStateManager.instance().get_state_ptr(EState.GAME).show_dialogue(dlg, commander, false)
			return true
		elif card_id == CARD_ID.SUPPLY_LINE_CARD:
			if get_card_rounds(CARD_ID.SUPPLY_LINE_CARD) > 0:
				return false
			for i in area.get_num_armies():
				area.revert_army_strength(i)
			money -= card_price
			industry -= card_industry
			_card_rounds[card_id] = card.round
			g_SoundRes.play_char_se(SND_EFFECT.SUPPLY_WAV)
			return true
		elif card_id == CARD_ID.ACE_FORCES_CARD:
			if get_card_rounds(CARD_ID.ACE_FORCES_CARD) > 0:
				return false
			area.get_army(army_index).upgrade()
			area.render()
			g_SoundRes.play_char_se(SND_EFFECT.LV_UP_WAV)
			money -= card_price
			industry -= card_industry
			_card_rounds[card_id] = card.round
			return true
		else:
			return false
	else:
		return false


func can_buy_card(card: CardDef) -> bool:
	if not is_card_unlock(card):
		return false
	var card_id := card.id
	if card_id == CARD_ID.COMMANDER_CARD:
		if not can_use_commander():
			return false
	elif card_id == CARD_ID.RESEARCH_CARD:
		if tech_level > 4 or research_round > 0:
			return false
	elif get_card_rounds(card_id) > 0:
		return false
	return is_enough_money(card) and is_enough_industry(card)


func is_card_unlock(card: CardDef) -> bool:
	return card.tech <= tech_level


func can_use_commander() -> bool:
	return not commander_alive and commander_round == 0


func get_card_rounds(card_id: int) -> int:
	return _card_rounds[card_id]


func is_enough_money(card: CardDef) -> bool:
	return get_card_price(card) <= money


func get_card_price(card: CardDef) -> int:
	var price := card.price
	if card.id == CARD_ID.RESEARCH_CARD:
		price *= tech_level
	elif card.id == CARD_ID.COMMANDER_CARD:
		price += 5 * get_commander_level()
	return price


func is_enough_industry(card: CardDef) -> bool:
	return get_card_industry(card) <= industry


func get_card_industry(card: CardDef) -> int:
	var x := card.industry
	if card.id == CARD_ID.RESEARCH_CARD:
		x *= tech_level
	return x


func check_card_target_army(card: CardDef, area_id: int, army_index: int) -> bool:
	var area = g_Scene.get_area(area_id)
	if area == null or area.country == null:
		return false
	var army = area.get_army(army_index)
	if army == null:
		return false
	match card.id:
		CARD_ID.CARRIER_CARD:
			return army.cards & (1<<2) == 0 and area.sea == 0
		CARD_ID.ASSAULT_ART_CARD:
			return army.cards & (1<<0) == 0
		CARD_ID.DEFEND_ART_CARD:
			return army.cards & (1<<1) == 0
		CARD_ID.COMMANDER_CARD:
			return area.country.can_use_commander() and army.cards & (1<<3) == 0
	return false


func set_card_targets(card: CardDef) -> void:
	if card.type == 2:
		for i in g_Scene.get_num_areas():
			if check_card_target_area(card, i):
				if card.id == CARD_ID.AIRBORNE_FORCE_CARD:
					g_Scene.get_area(i).target = 1
				else:
					g_Scene.get_area(i).target = 2
	else:
		for i in area_list:
			if check_card_target_area(card, i):
				g_Scene.get_area(i).target = 1


func check_card_target_area(card: CardDef, area_id: int) -> bool:
	var area = g_Scene.get_area(area_id)
	if area == null or area.country == null:
		return false
	if not is_card_unlock(card):
		return false
	match card.type:
		0:
			if area.country != self or area.get_num_armies() == 4:
				return false
			match card.id:
				CARD_ID.INFANTRY_CARD:
					return area.get_city_level() > 2
				CARD_ID.ARMOUR_CARD:
					return area.get_industry_level() > 0
				CARD_ID.ARTILLERY_CARD:
					return area.get_industry_level() > 0
				CARD_ID.ROCKET_CARD:
					return area.get_industry_level() > 2
				CARD_ID.TANK_CARD:
					return area.get_industry_level() > 1
				CARD_ID.HEAVY_TANK_CARD:
					return area.get_industry_level() > 2
		1:
			return area.country == self and area.type == 2 and area.get_num_armies() == 0
		2:
			match card.id:
				CARD_ID.AIR_STRIKE_CARD:
					if area.country == self or area.get_num_armies() <= 0:
						return false
					return get_min_dst_to_airport(area_id) < airstrike_radius()
				CARD_ID.BOMBER_CARD:
					if area.country == self or area.get_num_armies() <= 0:
						return false
					return get_min_dst_to_airport(area_id) < airstrike_radius()
				CARD_ID.AIRBORNE_FORCE_CARD:
					if area.sea != 0:
						return false
					if area.country == self:
						if area.get_num_armies() > 3:
							return false
					else:
						if area.get_num_armies() > 0:
							return false
					return get_min_dst_to_airport(area_id) < airstrike_radius()
				CARD_ID.NUCLEAR_BOMB_CARD:
					if area.country == self or area.get_num_armies() <= 0:
						return false
					return get_min_dst_to_airport(area_id) < airstrike_radius()
		3:
			if area.country != self or area.sea != 0:
				return false
			match card.id:
				CARD_ID.CITY_CARD:
					return area.can_construct(1)
				CARD_ID.INDUSTRY_CARD:
					return area.can_construct(2)
				CARD_ID.AIRPORT_CARD:
					return area.can_construct(3)
				CARD_ID.LAND_FORT_CARD:
					return area.installation == 0
				CARD_ID.ENTRENCHMENT_CARD:
					return area.installation == 0
				CARD_ID.ANTIAIRCRAFT_CARD:
					return area.installation == 0
				CARD_ID.RADAR_CARD:
					return area.installation == 0
		4:
			match card.id:
				CARD_ID.RESEARCH_CARD:
					return false
				CARD_ID.CARRIER_CARD:
					return area.country == self\
						and area.get_num_armies() > 0\
						and area.sea == 0\
						and not area.has_army_card(0, 2)
				CARD_ID.ASSAULT_ART_CARD:
					return area.country == self\
						and area.get_num_armies() > 0\
						and not area.has_army_card(0, 0)
				CARD_ID.DEFEND_ART_CARD:
					return area.country == self\
						and area.get_num_armies() > 0\
						and not area.has_army_card(0, 1)
				CARD_ID.COMMANDER_CARD:
					return can_use_commander()\
						and area.country == self\
						and area.get_num_armies() > 0\
						and not area.has_army_card(0, 3)
				CARD_ID.SUPPLY_LINE_CARD:
					if area.country != self:
						return false
					for i in area.get_num_armies():
						var army = area.get_army(i)
						if army.strength < army.get_max_strength():
							return true
					return false
				CARD_ID.ACE_FORCES_CARD:
					return area.country == self\
						and area.get_num_armies() > 0\
						and area.get_army(0).level <= 3
	return false


func airstrike_radius() -> float:
	if get_war_medal_level(WARMEDAL_ID.AIR_FORCE_MEDAL) <= 1:
		return 300.0
	else:
		return 400.0


func _set_war_medal_level(war_medal: int, level: int) -> void:
	_war_medal[war_medal] = level


func get_war_medal_level(war_medal: int) -> int:
	return _war_medal[war_medal]


func turn_begin() -> void:
	if research_round > 0:
		research_round -= 1
		if research_round == 0:
			tech_level += 1
	if g_GameManager.current_round > 0:
		_collect_taxes()
		_collect_industry()
	for i in area_list:
		g_Scene.get_area(i).turn_begin()


func _collect_taxes() -> void:
	money = mini(money + get_taxes(), 9999)


func get_taxes() -> int:
	var s := 0
	for i in area_list:
		s += g_Scene.get_area(i).get_real_tax()
	var l := get_war_medal_level(WARMEDAL_ID.COMMERCE_MEDAL)
	if l > 0:
		@warning_ignore("integer_division")
		s += s * l / 10
	@warning_ignore("narrowing_conversion")
	return s * tax_factor


func _collect_industry() -> void:
	industry = mini(industry + get_industrys(), 9999)


func get_industrys() -> int:
	var s := 0
	for i in area_list:
		s += g_Scene.get_area(i).get_industry()
	var l := get_war_medal_level(WARMEDAL_ID.COMMERCE_MEDAL)
	if l > 0:
		@warning_ignore("integer_division")
		s += s * l / 10
	@warning_ignore("narrowing_conversion")
	return s * tax_factor


func be_conquested_by(_conqueror: CCountry) -> void:
	for i in area_list:
		g_Scene.get_area(i).clear_all_army()
		g_Scene.set_area_country(i, null)
	area_list.clear()
	_capital_list.clear()


func is_local_player() -> bool:
	if ai:
		return false
	if g_GameManager.game_mode != 4:
		return true
	else:
		# TODO: multiplayer
		return true
