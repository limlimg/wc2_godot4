extends Control

const _CObjectDef = preload("res://app/src/main/cpp/c_object_def.gd")
const _ecTextureRes = preload("res://app/src/main/cpp/ec_texture_res.gd")
const _ecLibrary = preload("res://app/src/main/cpp/ec_library.gd")
const _lib = preload("res://app/src/main/cpp/native-lib.gd")
const _UnitMotions = preload("res://app/src/main/cpp/unit_motions.gd")
const _UnitPositions = preload("res://app/src/main/cpp/unit_positions.gd")
const _ecEffectRes = preload("res://app/src/main/cpp/ec_effect_res.gd")
const _SndEffect = preload("res://app/src/main/cpp/snd_effect.gd").SND_EFFECT

@export
var battle_area: int:
	set = set_battle_area

@export
var side: int

@export
var opposite_scene: NodePath

@export
var crater_texture_res: _ecTextureRes

@export
var effect_texture_res: _ecTextureRes

var _fort: Node2D
var _units: Array[Node2D]
var _destroyed_units: Array[Node2D]
var _craters: Array[Sprite2D]
var _effects: Array[Node2D]
var _attack_tween: Tween
var _effect_tween: Tween

signal attack_completed

func set_battle_area(value: int) -> void:
	if value == battle_area:
		return
	battle_area = value
	var area := g_Scene.get_area(value)
	if area == null:
		return
	var army := area.get_army(0)
	if army == null:
		return
	var bg_name: String
	if area.sea != 0:
		if area.type == 2:
			bg_name = "port_"
		else:
			bg_name = "sea_"
		match army.def.id:
			6:
				bg_name += "destroyer.png"
			7:
				bg_name += "cruiser.png"
			8:
				bg_name += "battleship.png"
			9:
				bg_name += "aircraft.png"
			_:
				bg_name += "carrier.png"
	elif area.type == 1:
		bg_name = "capital.png"
	else:
		match area.construction:
			3:
				bg_name = "airport.png"
			2:
				bg_name = "industry.png"
			1:
				match area.level:
					1:
						bg_name = "city1.png"
					2:
						bg_name = "city2.png"
					_:
						bg_name = "city3.png"
			_:
				bg_name = "normal1.png" if randi_range(0, 1) == 0 else "normal2.png"
	$BattleBg.texture = g_GameRes.get_battle_bg(bg_name)
	$AntiAircraft.visible = false
	$Entrenchment.visible = false
	_release_fort()
	if side == 2:
		match area.installation:
			2:
				$Entrenchment.visible = true
			3:
				$AntiAircraft.visible = true
			1:
				_create_fort()
	_release_units()
	_create_units()


func _release_fort() -> void:
	if _fort != null:
		_fort.queue_free()
		_fort = null


func _create_fort() -> void:
	var motions := _CObjectDef.instance().get_unit_motions("fort", "")
	var res := motions.res
	var fort_res := _ecTextureRes.new()
	var fort_lib := _ecLibrary.new()
	if _lib.g_content_scale_factor == 2.0 and fort_res.load_res(res + "_hd.xml", false):
		fort_lib.load_data(res + "_hd.bin")
	else:
		fort_res.load_res(res + ".xml", false)
		fort_lib.load_data(res + ".bin")
	fort_lib.texture_res = fort_res
	_fort = $Fort.create_instance()
	_fort.army_id = 16
	_fort.library = fort_lib
	_fort.motions = motions


func _release_units() -> void:
	for i in _units:
		i.queue_free()
	_units.clear()
	for i in _destroyed_units:
		i.queue_free()
	_destroyed_units.clear()


func _create_units() -> void:
	var area := g_Scene.get_area(battle_area)
	var army := area.get_army(0)
	var army_id := army.def.id
	var army_name := army.def.name
	var country_name := army.country.name
	var motions: _UnitMotions
	var positions: _UnitPositions
	var object_def := _CObjectDef.instance()
	motions = object_def.get_unit_motions(army_name,
		country_name if army_id >= 1 and army_id <= 5 else &"")
	positions = object_def.get_unit_positions(army_name)
	var res := motions.res
	if army_id > 5:
		if _lib.has_unit_motion(res, country_name):
			res += "_" + country_name
		else:
			res += "_ne"
	var unit_res := _ecTextureRes.new()
	var unit_lib := _ecLibrary.new()
	if _lib.g_content_scale_factor == 2.0 and unit_res.load_res(res + "_hd.xml", false):
		unit_lib.load_data(res + "_hd.bin")
	else:
		unit_res.load_res(res + ".xml", false)
		unit_lib.load_data(res + ".bin")
	unit_lib.texture_res = unit_res
	var num_dices := army.get_num_dices()
	for i in 5:
		if i < num_dices or army.is_navy():
			var unit = $Units/CBattleUnit.create_instance()
			unit.unit_index = i
			unit.army_id = army_id
			unit.library = unit_lib
			unit.motions = motions
			unit.position = Vector2(positions.x[i], positions.y[i])
			unit.scale = Vector2.ONE * positions.scale[i]
			if i >= num_dices:
				unit.set_destroyed()
				_destroyed_units.append(unit)
			else:
				_units.append(unit)


func attack() -> void:
	if _attack_tween != null:
		_attack_tween.kill()
	_attack_tween = create_tween()
	_attack_tween.tween_interval(0.2)
	if _fort != null:
		_attack_tween.tween_callback(_fort.attack)
	for i in _units.size():
		if i == 0:
			var army := g_Scene.get_area(battle_area).get_army(0)
			if army != null and army.def.id > 1:
				_attack_tween.tween_callback(get_node(opposite_scene).start_effect.bind(_units.size() + 1))
		else:
			_attack_tween.tween_interval(0.2)
		_attack_tween.tween_callback(_units[i].attack)


func start_effect(num: int) -> void:
	if _effect_tween != null:
		_effect_tween.kill()
	_effect_tween = create_tween()
	for i in num:
		_effect_tween.tween_interval(1.4 if i == 0 else 0.2)
		_effect_tween.tween_callback(func ():
			var rand_x := randi_range(0, 119) + 20.0
			var rand_y := randi_range(280 - 30 * _units.size(), 299)
			var rand_effect := randi_range(0, 4)
			if g_Scene.get_area(battle_area).sea != 0:
				match rand_effect:
					0:
						_add_effect("effect_strike2.xml", rand_x, rand_y)
					1:
						_add_effect("effect_strike2.xml", rand_x, rand_y)
					2:
						_add_effect("effect_strike3.xml", rand_x, rand_y)
					3:
						_add_effect("effect_strike3.xml", rand_x, rand_y)
					4:
						_add_effect("effect_strike5.xml", rand_x, rand_y)
			else:
				match rand_effect:
					0:
						_add_effect("effect_strike1.xml", rand_x, rand_y)
						_add_crater("crater2.png", rand_x, rand_y, 0.4)
					1:
						_add_effect("effect_strike1.xml", rand_x, rand_y)
						_add_crater("crater1.png", rand_x, rand_y, 0.4)
					2:
						_add_effect("effect_strike3.xml", rand_x, rand_y)
						_add_crater("crater1.png", rand_x, rand_y, 0.5)
					3:
						_add_effect("effect_strike4.xml", rand_x, rand_y)
						_add_crater("crater2.png", rand_x, rand_y, 0.5)
					4:
						_add_effect("effect_strike5.xml", rand_x, rand_y)
						_add_crater("crater2.png", rand_x, rand_y, 0.6)
			g_SoundRes.play_char_se(_SndEffect.STRIKE_WAV))


func _add_effect(effect_name: String, x: float, y: float) -> void:
	var effect = $ecEffect.create_instance()
	effect.effect_res.asset.name = effect_name
	effect.effect_res.texture_res = effect_texture_res
	effect.fire_at(x, y, 0.0)
	_effects.append(effect)
	effect.stopped().connect(func ():
		_effects[_effects.find(effect)] = _effects[-1]
		_effects.pop_back()
		effect.queue_free())


func clear_effect() -> void:
	for i in _effects:
		i.queue_free()


func _add_crater(image: StringName, crater_x: float, crater_y: float, crater_scale: float) -> void:
	var crater := $Craters/Sprite2D.duplicate()
	crater.texture = crater_texture_res.get_image(image)
	crater.position = Vector2(crater_x, crater_y)
	crater.scale = Vector2.ONE * crater_scale
	$Craters.add_child(crater)
	_craters.append(crater)


func clear_craters() -> void:
	for i in _craters:
		$Craters.remove_child(i)
		i.queue_free()


func _on_battle_unit_attack_completed() -> void:
	if not is_attacking():
		attack_completed.emit()


func is_attacking() -> bool:
	if _attack_tween != null and _attack_tween.is_running():
		return true
	for i in _units:
		if i.is_attacking():
			return true
	if _effect_tween != null and _effect_tween.is_running():
		return true
	return false


func destroy_units(num: int) -> void:
	for i in num:
		_units[-num + i].destroy()
