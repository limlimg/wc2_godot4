extends Node2D

var _tween: Tween

func aircraft_carrier_bomb(_attack_area: int, defend_area: int) -> void:
	bomb_area(defend_area, 4)


func bomb_area(area_id: int, action_type: int) -> void:
	var camera: CCamera = AppDelegate.g_Scene.camera
	var area: CArea = AppDelegate.g_Scene.get_area(area_id)
	var target_pos := area.army_pos
	var start_pos := target_pos
	start_pos.x = minf(-camera.position.x / camera.scale.x - 100, target_pos.x - 400)
	var t0 := _t_s(start_pos.x - target_pos.x)
	var end_pos := target_pos
	end_pos.x = maxf((-camera.position.x + camera.size.x) / camera.scale.x + 100, target_pos.x + 400)
	var t1 := _t_s(end_pos.x - target_pos.x)
	var card: CardDef
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_update_plane_pos, t0, t1, t1 - t0)
	if action_type == 1 or action_type == 4:
		$Plane/Fighter.visible = true
		$Plane/Bomber.visible = false
		var sub_tween := create_tween()
		var strike_x := target_pos.x - 150
		sub_tween.tween_interval(_t_s(strike_x) - t0)
		sub_tween.tween_callback(func ():
			var effect = $ecEffectManager.add_effect("effect_airstrike.xml", true)
			var y = $Plane.position.y + randi_range(-5, 4)
			effect.fire_at(target_pos.x - 50, y, 0.0)
		)
		sub_tween.tween_interval(0.0625)
		sub_tween.tween_callback(func ():
			var effect = $ecEffectManager.add_effect("effect_airstrike.xml", true)
			var y = $Plane.position.y + randi_range(-5, 4)
			effect.fire_at(target_pos.x - 30, y, 0.0)
			AppDelegate.g_SoundRes.play_char_se(SND_EFFECT.MACHINE_GUN_WAV)
		)
		sub_tween.tween_interval(0.0625)
		sub_tween.tween_callback(func ():
			var effect = $ecEffectManager.add_effect("effect_airstrike.xml", true)
			var y = $Plane.position.y + randi_range(-5, 4)
			effect.fire_at(target_pos.x - 10, y, 0.0)
			AppDelegate.g_SoundRes.play_char_se(SND_EFFECT.MACHINE_GUN_WAV)
		)
		sub_tween.tween_interval(0.0625)
		sub_tween.tween_callback(func ():
			var effect = $ecEffectManager.add_effect("effect_airstrike.xml", true)
			var y = $Plane.position.y + randi_range(-5, 4)
			effect.fire_at(target_pos.x + 10, y, 0.0)
			AppDelegate.g_SoundRes.play_char_se(SND_EFFECT.MACHINE_GUN_WAV)
		)
		_tween.parallel().tween_subtween(sub_tween)
		if action_type == 1:
			card = CObjectDef.instance().get_card_def(10)
	else:
		$Plane/Fighter.visible = false
		$Plane/Bomber.visible = true
		var sub_tween := create_tween()
		sub_tween.tween_interval(-t0 + 0.258)
		_tween.parallel().tween_subtween(sub_tween)
		if action_type == 2:
			card = CObjectDef.instance().get_card_def(11)
		elif action_type == 3:
			card = CObjectDef.instance().get_card_def(13)
	var country := g_GameManager.get_cur_country()
	if country != null:
		if action_type != 4:
			_tween.tween_callback(country.use_card.bind(card, area_id, 0))
		_tween.tween_callback(func ():
			var fight := CFight.new()
			fight.air_strikes_attack(country, area_id, action_type)
			fight.apply_result())


func airborne(area_id: int) -> void:
	var camera: CCamera = AppDelegate.g_Scene.camera
	var area: CArea = AppDelegate.g_Scene.get_area(area_id)
	var target_pos := area.army_pos
	var start_pos := target_pos
	start_pos.x = minf(-camera.position.x / camera.scale.x - 100, target_pos.x - 400)
	var t0 := _t_s(start_pos.x)
	var end_pos := target_pos
	end_pos.x = maxf((-camera.position.x + camera.size.x) / camera.scale.x + 100, target_pos.x + 400)
	var t1 := _t_s(end_pos.x)
	var card: CardDef
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_update_plane_pos, t0, t1, t1 - t0)
	var sub_tween := create_tween()
	sub_tween.tween_interval(-t0)
	sub_tween.tween_callback(func ():
		var effect = $ecEffectManager.add_effect("effect_parachute.xml", true)
		var y = $Plane.position.y - 60
		effect.fire_at(target_pos.x, y, 0.0)
	)
	sub_tween.tween_interval(0.632)
	_tween.parallel().tween_subtween(sub_tween)
	card = CObjectDef.instance().get_card_def(12)
	var country := g_GameManager.get_cur_country()
	if country != null:
		_tween.tween_callback(country.use_card.bind(card, area_id, 0))


func _update_plane_pos(t: float) -> void:
	$Plane.position.x = _s_t(t)


static func _s_t(t: float) -> float:
	if t < -0.5:
		return -400 * exp(-2 * t - 1)
	elif t > 0.5:
		return 400 * exp(2 * t - 1)
	else:
		return 800 * t


static func _t_s(s: float) -> float:
	if s < -400:
		return -(log(s / -400) + 1) / 2
	elif s > 400:
		return (log(s / 400) + 1) / 2
	else:
		return s / 800


func is_bombing() -> bool:
	return _tween != null and _tween.is_running()
