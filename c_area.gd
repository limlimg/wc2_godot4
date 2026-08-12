class_name CArea
extends Object

var id: int
var type: int
var tax: int
var army_pos: Vector2
var construction_pos: Vector2
var installation_pos: Vector2
var sea: int

var construction: int:
	set(value):
		if value != construction:
			construction = value
			render_building()


var level: int:
	set(value):
		if value != level:
			level = value
			render_building()


var installation: int:
	set(value):
		if value != installation:
			installation = value
			render_building()


var country: CCountry:
	set(value):
		if value != country:
			country = value
			render_building()
			render()


var _armies: Array[CArmy]:
	set(value):
		if value != _armies:
			_armies = value
			render()


var army_drafting: bool
var army_moving_in: bool
var army_moving_to_front: bool

var _army_offset: Vector2:
	set(value):
		if value != _army_offset:
			_army_offset = value


var _army_moving_in_timer: float
var _army_moving_in_will_occupy: bool
var _army_moving_in_will_complain: bool
var _army_moving_in_complainer: StringName
var canvas_item_root: RID
var _canvas_item_flag: RID
var _canvas_item_building: RID
var _canvas_item_army: RID
var canvas_item_arrow: RID

func init(init_id: int, info: AreaInfo) -> void:
	id = init_id
	type = info.type
	tax = info.tax
	army_pos = info.army_pos
	construction_pos = info.construction_pos
	installation_pos = info.installation_pos
	sea = info.sea
	construction = info.construction
	level = info.level
	country = null
	_armies.clear()
	if not canvas_item_root.is_valid():
		canvas_item_root = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_z_index(canvas_item_root, -2)
	RenderingServer.canvas_item_set_sort_children_by_y(canvas_item_root, true)
	if not _canvas_item_flag.is_valid():
		_canvas_item_flag = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(_canvas_item_flag, canvas_item_root)
	RenderingServer.canvas_item_set_transform(_canvas_item_flag, Transform2D.IDENTITY.translated(construction_pos))
	RenderingServer.canvas_item_set_z_index(_canvas_item_flag, 2)
	if not _canvas_item_building.is_valid():
		_canvas_item_building = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(_canvas_item_building, _canvas_item_flag)
	RenderingServer.canvas_item_set_transform(_canvas_item_building, Transform2D.IDENTITY.translated(-construction_pos))
	RenderingServer.canvas_item_set_z_index(_canvas_item_building, -1)
	if not _canvas_item_army.is_valid():
		_canvas_item_army = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(_canvas_item_army, canvas_item_root)
	RenderingServer.canvas_item_set_transform(_canvas_item_army, Transform2D.IDENTITY.translated(army_pos))
	RenderingServer.canvas_item_set_z_index(_canvas_item_army, 2)
	if not canvas_item_arrow.is_valid():
		canvas_item_arrow = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(canvas_item_arrow, _canvas_item_army)
	render_building()
	render()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if canvas_item_root.is_valid():
			RenderingServer.free_rid(canvas_item_root)
		if _canvas_item_flag.is_valid():
			RenderingServer.free_rid(_canvas_item_flag)
		if _canvas_item_building.is_valid():
			RenderingServer.free_rid(_canvas_item_building)
		if _canvas_item_army.is_valid():
			RenderingServer.free_rid(_canvas_item_army)
		if canvas_item_arrow.is_valid():
			RenderingServer.free_rid(canvas_item_arrow)


func can_construct(construct_type: int) -> bool:
	if sea:
		return false
	if construction == 0:
		return true
	if construct_type != construction:
		return false
	match construction:
		1:
			return level <= 3
		2:
			return level <= 2
		3:
			return level <= 0
	return false


func construct(construct_type: int) -> void:
	if construction != 0:
		level += 1
		return
	construction = construct_type
	level = _min_construction_level(construct_type)


func _min_construction_level(construct_type: int) -> int:
	if type == 1 and construct_type == 1:
		return 4
	elif type == 1 and construct_type == 2:
		return 3
	elif type == 3 and construct_type == 1:
		return 3
	elif type == 3 and construct_type == 2:
		return 2
	elif type == 4 and construct_type == 1:
		return 2
	else:
		return 1


func set_construction(value: int, level_value: int) -> void:
	construction = value
	match value:
		0:
			level = 0
		1:
			level = min(level_value, 4)
		2:
			level = min(level_value, 3)
		3:
			level = min(level_value, 1)
		_:
			level = level_value


func reduce_construction_level() -> void:
	if construction == 0:
		return
	if level <= _min_construction_level(construction):
		construction = 0
		level = 0
	else:
		level -= 1


func destroy_construction() -> void:
	construction = 0
	level = 0


func get_real_tax() -> int:
	return tax + 5 * get_city_level()


func get_city_level() -> int:
	var city_level := _min_construction_level(1) - 1
	if construction == 1 and level > city_level:
		city_level = level
	return city_level


func get_industry() -> int:
	return 5 * get_industry_level()


func get_industry_level() -> int:
	var industry_level := _min_construction_level(2) - 1
	if construction == 2 and level > industry_level:
		industry_level = level
	return industry_level


func get_num_armies() -> int:
	return _armies.size()


func get_army(idx: int) -> CArmy:
	if idx < 0 or idx >= _armies.size():
		return null
	return _armies[idx]


func add_army(army: CArmy, at_bottom: bool) -> bool:
	if _armies.size() > 3:
		return false
	if at_bottom:
		_armies.append(army)
	else:
		_armies.push_front(army)
	render()
	return true


func remove_army(army: CArmy) -> void:
	var idx := get_army_idx(army)
	if idx >= 0:
		_armies.remove_at(idx)
		render()


func get_army_idx(army: CArmy) -> int:
	return _armies.find(army)


func move_army_to_front(army, animated: bool) -> void:
	if army is CArmy:
		army = get_army_idx(army)
	if army is not int or army <= 0:
		return
	var moved_army := _armies[army]
	for i in army:
		_armies[army - i] = _armies[army - i - 1]
	_armies[0] = moved_army
	render()
	if animated:
		army_moving_to_front = true
	_army_offset = Vector2.ZERO


func draft_army(army_id: int) -> CArmy:
	if _armies.size() > 3 or country == null:
		return null
	var army_def := CObjectDef.instance().get_army_def(army_id, country.name)
	if army_def == null:
		return null
	var new_army := CArmy.new()
	new_army.def = army_def
	new_army.country = country
	new_army.ai_active = true
	add_army(new_army, false)
	army_drafting = true
	_army_offset = Vector2(0.0, -60.0)
	g_SoundRes.play_char_se(SND_EFFECT.DRAFT_WAV)
	return new_army


func move_army_to(to: CArea) -> void:
	if _armies.is_empty() or to._armies.size() > 3:
		return
	var army := _armies[0]
	if army.movement <= 0:
		return
	var will_occupy := country != to.country
	var will_compain := false
	var compainer: StringName
	if to.country != null:
		if to.country.ai and not country.ai and to.country.alliance == country.alliance:
			will_compain = randi_range(0, 1) != 0
		compainer = to.country.get_commander_name()
		to.country.remove_area(to.id)
	country.add_area(to.id)
	to.country = country
	if to.country != null and to.country.is_conquested():
		to.country.be_conquested_by(country)
	remove_army(army)
	if sea or to.sea:
		army.movement = 0
	else:
		army.movement -= 1
	to._set_move_in_army(self, army, will_occupy, will_compain, compainer)
	if _armies.is_empty():
		g_Scene.adjacent_areas_encirclement(id)


func _set_move_in_army(from: CArea, army: CArmy, will_occupy: bool, will_compain: bool, compainer: StringName) -> void:
	var from_pos := from.army_pos
	var to_pos := army_pos
	_army_offset = from_pos - to_pos
	_army_moving_in_will_occupy = will_occupy
	if from_pos.x <= to_pos.x:
		army.direction = 1.0
	else:
		army.direction = -1.0
	_armies.push_front(army)
	army_moving_in = true
	_army_moving_in_will_complain = will_compain
	_army_moving_in_complainer = compainer
	_army_moving_in_timer = 0.25
	render()


func occupy_area(to: CArea) -> void:
	if _armies.is_empty():
		return
	var army := _armies[0]
	var will_occupy := country != to.country
	if to.country != null:
		to.country.remove_area(to.id)
	country.add_area(to.id)
	to.country = country
	if to.country != null and to.country.is_conquested():
		to.country.be_conquested_by(country)
	remove_army(army)
	to._set_move_in_army(self, army, will_occupy, false, &"")
	if _armies.is_empty():
		g_Scene.adjacent_areas_encirclement(id)


func clear_all_army() -> void:
	_armies.clear()
	render()


func set_army_dir(idx: int, dir: float) -> void:
	if idx < _armies.size():
		_armies[idx].direction = dir
		render()


func add_army_card(idx: int, card: int) -> void:
	if idx < _armies.size():
		var army := _armies[idx]
		if army != null:
			army.cards |= 1 << card
			render()


func _del_army_card(idx: int, card: int) -> void:
	if idx < _armies.size():
		var army := _armies[idx]
		if army != null:
			army.cards &= ~(1 << card)
			render()


func has_army_card(idx: int, card: int = -1) -> bool:
	if card == -1:
		card = idx
		idx = 0
		while idx < _armies.size():
			if _armies[idx] != null:
				break
			idx += 1
	if idx < _armies.size():
		var army := _armies[idx]
		if army != null:
			return (army.cards & (1 << card)) != 0
	return false


func revert_army_strength(idx: int) -> void:
	if idx < _armies.size():
		var army := _armies[idx]
		if army != null:
			army.strength = army.get_max_strength()
			render()


func lost_army_strength(idx: int, value: int) -> bool:
	if idx >= _armies.size():
		return false
	var army = _armies[idx]
	if army == null:
		return false
	if army.lost_strength(value):
		if army.cards & (1<<3) != 0:
			country.commander_die()
		remove_army(army)
		if sea and _armies.is_empty() and country != null and country.is_conquested():
			country.be_conquested_by(null)
		return true
	else:
		render()
		return false


func _add_army_strength(idx: int, value: int) -> void:
	if idx < _armies.size():
		var army := _armies[idx]
		if army != null:
			army.add_strength(value)
			render()


func all_army_poisoning() -> void:
	for i in _armies:
		i.poisoning()
	render()


func upgrade_army(idx: int) -> void:
	if idx < _armies.size():
		var army := _armies[idx]
		if army != null:
			army.upgrade()
			render()


func _set_all_army_movement(value: int) -> void:
	for i in _armies:
		i.movement = value
	render()


func is_active() -> bool:
	for i in _armies:
		if i.movement > 0 and i.ai_active:
			return true
	return false


func set_army_active(idx: int, value: bool) -> void:
	if idx < _armies.size():
		var army := _armies[idx]
		if army != null:
			army.ai_active = value


func is_army_active(idx: int) -> bool:
	if idx >= _armies.size():
		return false
	var army := _armies[idx]
	if army == null:
		return false
	return army.ai_active


func check_encirclement() -> bool:
	if country == null:
		return false
	for i in g_Scene.get_num_adjacent_areas(id):
		var adj_area: CArea = g_Scene.get_adjacent_area(id, i)
		if adj_area.country == null\
			or adj_area.country.alliance == 4 or adj_area.country.alliance == country.alliance\
			or adj_area._armies.is_empty():
			return false
	return true


func encirclement() -> void:
	if check_encirclement():
		for i in _armies:
			i.set_morale(1)
	else:
		for i in _armies:
			if i.morale == 1:
				i.set_morale(0)
	render()


func update(delta: float) -> void:
	if army_drafting:
		var y := minf(_army_offset.y + 320.0 * delta, 0.0)
		_army_offset.y = y
		if y >= 0.0:
			army_drafting = false
			g_Scene.adjacent_areas_encirclement(id)
		render()
	if army_moving_in:
		if _army_moving_in_timer > delta:
			_army_offset = _army_offset.lerp(Vector2.ZERO, delta / _army_moving_in_timer)
			_army_moving_in_timer -= delta
		else:
			_army_offset = Vector2.ZERO
			army_moving_in = false
			if _army_moving_in_will_occupy:
				g_SoundRes.play_char_se(SND_EFFECT.OCCUPY_WAV)
			if _army_moving_in_will_complain and not _army_moving_in_complainer.is_empty():
					var dlg := "commander complain {0}".format([randi_range(1, 2)])
					CStateManager.instance().get_state_ptr(EState.GAME).show_dialogue(dlg, _army_moving_in_complainer, false)
			if _armies.size() == 1:
				g_Scene.adjacent_areas_encirclement.bind(id)
		render()
	if army_moving_to_front:
		var v := Vector2(-_army_offset.x - 12.0, -_army_offset.y / (1.0 if _army_offset.y >= 0 else 2.0))
		var a := minf(v.angle() + 12 * delta, 5.96902597 - PI)
		print(_army_offset, v, v.angle(), a)
		_army_offset = Vector2(-cos(a) * 12.0 - 12.0, -sin(a) * (12.0 if a <= 0 else 24.0))
		print(_army_offset)
		if a >= 5.96902597 - PI:
			_army_offset = Vector2.ZERO
			army_moving_to_front = false
			g_Scene.reset_target()
		render()


func render_building() -> void:
	if not g_Scene.visible:
		return
	RenderingServer.canvas_item_clear(_canvas_item_building)
	if type == 2:
		g_GameRes.render_port(_canvas_item_building, construction_pos.x, construction_pos.y)
	elif country != null:
		g_GameRes.render_construction(_canvas_item_building, construction, level, construction_pos.x, construction_pos.y)
		g_GameRes.render_installation(_canvas_item_building, installation, installation_pos.x, installation_pos.y)


func render() -> void:
	if not g_Scene.visible:
		return
	if country != null:
		RenderingServer.canvas_item_clear(_canvas_item_flag)
		g_GameRes.render_flag(_canvas_item_flag, country.name, 0.0, 0.0)
		RenderingServer.canvas_item_clear(_canvas_item_army)
		var _moving_army := army_drafting or army_moving_in or army_moving_to_front
		var i := 1 if _moving_army else 0
		if _armies.size() > i:
			_render_army(0.0, 0.0, _armies.size() - i, _armies[i])
		if _moving_army:
			_render_army(_army_offset.x, _army_offset.y, 1, _armies[0])


func _render_army(x: float, y: float, stack: int, army: CArmy) -> void:
	var morale_color: Color
	match army.morale:
		1:
			if army.movement > 0:
				morale_color = Color.from_rgba8(0xFF, 0x40, 0x40)
			else:
				morale_color = Color.from_rgba8(0xC0, 0x40, 0x40)
		2:
			if army.movement > 0:
				morale_color = Color.from_rgba8(0x40, 0x40, 0xFF)
			else:
				morale_color = Color.from_rgba8(0x40, 0x40, 0xC0)
		0:
			if army.movement > 0:
				morale_color = Color.from_rgba8(0xFF, 0xFF, 0xFF)
			else:
				morale_color = Color.from_rgba8(0xC0, 0xC0, 0xC0)
	g_GameRes.render_army(_canvas_item_army, country.name, country.alliance, stack, x, y, army.def.id, morale_color, sea, army.direction)
	if army.is_navy():
		y += 8.0
	elif sea != 0 and army.cards & (1<<2) != 0:
		y += 4.0
	g_GameRes.render_army_info(_canvas_item_army, stack, x, y, army.strength, army.get_max_strength(), army.movement, army.cards, army.level)
	if army.cards & (1<<3) != 0:
		if country.ai:
			g_GameRes.render_ai_commander_medal(_canvas_item_army, stack, x, y, country.name, country.alliance)
		else:
			g_GameRes.render_commander_medal(_canvas_item_army, stack, x, y, country.get_commander_level())


func turn_begin() -> void:
	for i in _armies:
		i.turn_begin()
		if sea and i.movement > 1:
			i.movement = 1
	render()


func turn_end() -> void:
	var max_level := get_city_level()
	max_level = maxi(get_industry_level(), max_level)
	max_level = maxi(1 if construction == 3 else 0, max_level)
	var movement_add := 3 * max_level
	match type:
		1:
			movement_add += 9
		2:
			movement_add += 6
		3:
			movement_add += 7
		4:
			movement_add += 5
		_:
			movement_add += 3
	for i in _armies:
		if i.movement > 0:
			if type == 2 and i.is_navy():
				i.add_strength(2 * movement_add)
			else:
				i.add_strength(movement_add)
		var level_add = AppDelegate.get_army_ability(i.level)[2]
		if i.cards & (1<<3) != 0:
			level_add = maxi(AppDelegate.get_commander_ability(country.get_commander_level())[2], level_add)
		i.add_strength(level_add)
		i.turn_end()
	render()


func save_area(info: SaveAreaInfo) -> void:
	info.id = id
	info.construction = construction
	info.level = level
	info.installation = installation
	info.army_count = _armies.size()
	var army: Array[SaveArmyInfo]
	army.resize(info.army_count)
	for i in info.army_count:
		army[i] = SaveArmyInfo.new()
	for i in info.army_count:
		_armies[i].save_army(army[i])
	info.army = army


func load_area(info: SaveAreaInfo) -> void:
	id = info.id
	construction = info.construction
	level = info.level
	installation = info.installation
	if country != null:
		for i in info.army_count:
			var new_army := CArmy.new()
			new_army.def = CObjectDef.instance().get_army_def(info.army[i].type, country.name)
			new_army.country = country
			new_army.load_army(info.army[i])
			add_army(new_army, true)
