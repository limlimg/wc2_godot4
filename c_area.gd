class_name CArea
extends Sprite2D

var id: int
var type: int
var tax: int

var army_pos: Vector2:
	get():
		return $Army.position + position
	set(value):
		$Army.position = value - position


var construction_pos: Vector2:
	get():
		return $Flag.position + position
	set(value):
		$Flag.position = value - position
	

var installation_pos: Vector2

var sea: int

var construction: int:
	set(value):
		if value != construction:
			construction = value
			_render_building()


var level: int:
	set(value):
		if value != level:
			level = value
			_render_building()


var installation: int:
	set(value):
		if value != installation:
			installation = value
			_render_building()


var country: CCountry:
	set(value):
		if value != country:
			country = value
			_render_building()
			_render()


var _armies: Array[CArmy]:
	set(value):
		if value != _armies:
			_armies = value
			_render_army()


var arrow_texture: Texture2D:
	get():
		return $Army/Arrow.texture
	set(value):
		$Army/Arrow.texture = value
		$Army/ArrowShadow.visible = value != null


var arrow_offset: float:
	get():
		return $Army/Arrow.position.y
	set(value):
		$Army/Arrow.position.y = value
		$Army/ArrowShadow.position = Vector2(value / 2, value / 2)


var _building: Node2D
var _flag: Node2D
var _army: Node2D
var _tween_moving_army: Tween

signal complained(complainer: StringName)

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
	if _building != null:
		_building.queue_free()
		_building = null
	if _flag != null:
		_flag.queue_free()
		_flag = null
	if _army != null:
		_army.queue_free()
		_army = null
	_render_building()
	_render()


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
			level = min(level, 4)
		2:
			level = min(level, 3)
		3:
			level = min(level, 1)
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
	_render_army()
	return true


func remove_army(army: CArmy) -> void:
	var idx := get_army_idx(army)
	if idx > 0:
		_armies.remove_at(idx)
		_render_army()


func get_army_idx(army: CArmy) -> int:
	return _armies.find(army)


func move_army_to_front(army, animated: bool) -> void:
	if army is CArmy:
		army = get_army_idx(army)
	if army is not int or army <= 0:
		return
	if _tween_moving_army != null:
		_tween_moving_army.kill()
		_tween_moving_army = null
	var moved_army := _armies[army]
	for i in army:
		_armies[army - i] = _armies[army - i - 1]
	_armies[0] = moved_army
	_render_army()
	if animated:
		_tween_moving_army = create_tween()
		_tween_moving_army.tween_method(_move_to_front, 0.0, 2.0 * PI, 0.5)
		_tween_moving_army.tween_callback(AppDelegate.g_Scene.reset_target)
	else:
		_army.position = Vector2.ZERO


func _move_to_front(angle: float) -> void:
	var x := cos(angle) * 12.0 - 12.0
	var y := sin(angle) * 12.0 if angle <= PI else sin(angle) * 24.0
	_army.position = Vector2(x, y)


func draft_army(army_id: int) -> void:
	if _armies.size() > 3 or country == null:
		return
	var army_def := CObjectDef.instance().get_army_def(army_id, country.name)
	if army_def == null:
		return
	var new_army := CArmy.new()
	new_army.def = army_def
	new_army.country = country
	new_army.ai_active = true
	add_army(new_army, false)
	if _tween_moving_army != null:
		_tween_moving_army.kill()
	_tween_moving_army = create_tween()
	_army.position = Vector2(0.0, -60.0)
	AppDelegate.g_SoundRes.play_char_se(SND_EFFECT.DRAFT_WAV)
	_tween_moving_army.tween_property(_army, ^"position", Vector2.ZERO, 0.1875)
	_tween_moving_army.tween_callback(AppDelegate.g_Scene.adjacent_areas_encirclement.bind(id))


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
		AppDelegate.g_Scene.adjacent_areas_encirclement(id)


func _set_move_in_army(from: CArea, army: CArmy, will_occupy: bool, will_compain: bool, compainer: StringName) -> void:
	_armies.push_front(army)
	var from_pos := from.army_pos
	var to_pos := army_pos
	if from_pos.x <= to_pos.x:
		army.direction = 1.0
	else:
		army.direction = -1.0
	_render_army()
	if _tween_moving_army != null:
		_tween_moving_army.kill()
	_tween_moving_army = create_tween()
	_army.position = to_pos - from_pos
	_tween_moving_army.tween_property($Army, ^"position", Vector2.ZERO, 0.25)
	if will_occupy:
		_tween_moving_army.tween_callback(AppDelegate.g_SoundRes.play_char_se.bind(SND_EFFECT.OCCUPY_WAV))
	if will_compain and not compainer.is_empty():
		_tween_moving_army.tween_callback(complained.emit.bind(compainer))
	if _armies.is_empty():
		_tween_moving_army.tween_callback(AppDelegate.g_Scene.adjacent_areas_encirclement.bind(id))


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
		AppDelegate.g_Scene.adjacent_areas_encirclement(id)


func clear_all_army() -> void:
	_armies.clear()
	_render_army()


func set_army_dir(idx: int, dir: float) -> void:
	if idx < _armies.size():
		_armies[idx].direction = dir
		_render_army()


func add_army_card(idx: int, card: int) -> void:
	if idx < _armies.size():
		var army := _armies[idx]
		if army != null:
			army.cards |= 1 << card
			_render_army()


func _del_army_card(idx: int, card: int) -> void:
	if idx < _armies.size():
		var army := _armies[idx]
		if army != null:
			army.cards &= ~(1 << card)
			_render_army()


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
			_render_army()


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
		_render_army()
		return false


func _add_army_strength(idx: int, value: int) -> void:
	if idx < _armies.size():
		var army := _armies[idx]
		if army != null:
			army.add_strength(value)
			_render_army()


func all_army_poisoning() -> void:
	for i in _armies:
		i.poisoning()
	_render_army()


func upgrade_army(idx: int) -> void:
	if idx < _armies.size():
		var army := _armies[idx]
		if army != null:
			army.upgrade()
			_render_army()


func _set_all_army_movement(value: int) -> void:
	for i in _armies:
		i.movement = value
	_render_army()


func is_active() -> bool:
	for i in _armies:
		if i.ai_active:
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
	for i in AppDelegate.g_Scene.get_num_adjacent_areas(id):
		var adj_area: CArea = AppDelegate.g_Scene.get_adjacent_area(id, i)
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
	_render_army()


func _render_building() -> void:
	if country == null:
		if _building != null:
			_building.queue_free()
			_building = null
	else:
		if _building == null:
			_building = $Flag/Building.create_instance()
			_building.installation_pos = installation_pos
			_building.area_type = type
		_building.construction_type = construction
		_building.construction_level = level
		_building.installation_type = installation


func _render() -> void:
	if country == null:
		if _flag != null:
			_flag.queue_free()
			_flag = null
	else:
		if _flag == null:
			_flag = $Flag/Flag.create_instance()
		_flag.country_name = country.name
	_render_army()


func _render_army() -> void:
	if country == null or _armies.is_empty():
		if _army != null:
			_army.queue_free()
			_army = null
	else:
		if _army == null:
			_army = $Army/Army.create_instance()
		_army.country = country.name
		_army.alliance = country.alliance
		_army.stack = _armies.size()
		var army := _armies[0]
		_army.id = army.def.id
		_army.is_navy = army.is_navy()
		_army.sea = sea
		_army.direction = army.direction
		_army.stength = army.strength
		_army.max_strength = army.get_max_strength()
		_army.movement = army.movement
		_army.cards = army.cards
		_army.level = army.level
		_army.commander_level = country.get_commander_level()
		_army.morale = army.morale
		_army.ai = country.ai


func turn_begin() -> void:
	for i in _armies:
		i.turn_begin()
		if sea and i.movement > 1:
			i.movement = 1
	_render_army()


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
	_render_army()


func save_area(info: SaveAreaInfo) -> void:
	info.id = id
	info.construction = construction
	info.level = level
	info.installation = installation
	info.army_count = _armies.size()
	for i in info.army_count:
		_armies[i].save_army(info.army[i])


func load_area(info: SaveAreaInfo) -> void:
	id = info.id
	construction = info.construction
	level = info.level
	installation = info.installation
	if country != null:
		for i in info.army_count:
			var new_army := CArmy.new()
			new_army.def = CObjectDef.instance().get_army_def(info.army[i].id, country.name)
			new_army.country = country
			new_army.load_army(info.army[i])
			add_army(new_army, true)
