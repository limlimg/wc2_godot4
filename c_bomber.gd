extends Node2D

var _start_area: int
var _target_area: int
var _target_x: float
var _effect_timer: float
var _effect_ended: bool
var _effect_playing: bool
var _is_airborne: bool
var _action_type: int
var _air_strike_shot: int

func init():
	pass


func aircraft_carrier_bomb(attack_area: int, defend_area: int) -> void:
	bomb_area(defend_area, 4)
	_start_area = attack_area


func bomb_area(area_id: int, action_type: int) -> void:
	_target_area = area_id
	var target_pos := g_Scene.get_area(area_id).army_pos
	_target_x = target_pos.x
	$Plane.position.y = target_pos.y
	var camera: CCamera = g_Scene.camera
	var start_x = minf(camera.camera_position.x - camera.size.x / 2 / camera.camera_zoom.x - 100.0, _target_x - 400.0)
	$Plane.position.x = start_x
	_action_type = action_type
	visible = true
	show()
	_effect_ended = false
	_effect_playing = false
	_is_airborne = false
	_air_strike_shot = 0


func airborne(area_id: int) -> void:
	_target_area = area_id
	var target_pos :=g_Scene.get_area(area_id).army_pos
	_target_x = target_pos.x
	$Plane.position.y = target_pos.y
	var camera: CCamera = g_Scene.camera
	var start_x = minf(camera.camera_position.x - camera.size.x / 2 / camera.camera_zoom.x - 100.0, _target_x - 400.0)
	$Plane.position.x = start_x
	visible = true
	_is_airborne = true
	_effect_ended = false
	_effect_playing = false
	_air_strike_shot = 0


func is_bombing() -> bool:
	return visible or _effect_playing


func update(delta: float) -> void:
	if not visible:
		return
	var t0 := _t_s($Plane.position.x - _target_x)
	var t := t0 + delta
	$Plane.position.x = _s_t(t) + _target_x
	var camera: CCamera = g_Scene.camera
	var end_x = maxf(camera.camera_position.x + camera.size.x / 2 / camera.camera_zoom.x + 100.0, _target_x + 400.0)
	if $Plane.position.x > end_x and _effect_ended:
		visible = false
	if not _is_airborne and _action_type == 1 or _action_type == 4:
		if _air_strike_shot <= 4:
			if t > _t_s((_air_strike_shot - 3) * 50.0):
				var effect = ecEffectManager.instance().add_effect("effect_airstrike.xml", true)
				var y = $Plane.position.y + randi_range(-5, 4)
				effect.fire_at(_target_x - 50.0 + 20.0 * _air_strike_shot, y, 0.0)
				if _air_strike_shot != 0:
					g_SoundRes.play_char_se(SND_EFFECT.MACHINE_GUN_WAV)
				_air_strike_shot += 1
	if not _effect_playing:
		if _is_airborne:
			if t0 < 0.0 and t >= 0.0:
				_effect_playing = true
				_effect_timer = sqrt(0.4)
				var effect = ecEffectManager.instance().add_effect("effect_parachute.xml", true)
				var y = $Plane.position.y - 60
				effect.fire_at(_target_x, y, 0.0)
		elif t0 < 0.0 and t >= 0.0:
				_effect_playing = true
				_effect_timer = sqrt(1.0 / 15.0)
	else:
		_effect_timer -= delta
		if _effect_timer <= 0.0:
			_effect_ended = true
			_effect_playing = false
			var country = g_GameManager.get_cur_country()
			if country != null:
				if _is_airborne:
					var card := CObjectDef.instance().get_card_def(CARD_ID.AIRBORNE_FORCE_CARD)
					if card != null:
						country.use_card(card, _target_area, 0)
				else:
					var fight := CFight.new()
					if _action_type != 4:
						var card: CardDef
						match _action_type:
							1:
								card = CObjectDef.instance().get_card_def(CARD_ID.AIR_STRIKE_CARD)
							2:
								card = CObjectDef.instance().get_card_def(CARD_ID.BOMBER_CARD)
							3:
								card = CObjectDef.instance().get_card_def(CARD_ID.NUCLEAR_BOMB_CARD)
						country.use_card(card, _target_area, 0)
						fight.air_strikes_attack(country, _target_area, _action_type)
					else:
						fight.air_strikes_attack(_start_area, _target_area)
					fight.apply_result()


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
