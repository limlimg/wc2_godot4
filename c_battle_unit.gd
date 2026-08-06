extends Node2D

@export
var unit_index: int

@export
var army_id: int

@export
var library: ecLibrary

@export
var motions: UnitMotions

var _motion_index: int
var _attack_timer: float
var _attack_ended: bool
var _effect_fire: Node2D
var _effect_exp: Node2D

func init() -> void:
	if army_id == 0:
		if unit_index == 1 or unit_index == 3:
			_motion_index = randi_range(0, 1) * 2
		else:
			_motion_index = randi_range(0, 1) * 2 + 1
	$StandBy.lib = library
	$StandBy.motion_name = motions.standby[_motion_index].name
	$StandBy.play()
	var attack_motion := motions.attack[_motion_index]
	$Attack.lib = library
	$Attack.motion_name = attack_motion.name
	$Attack.play()
	if not motions.destroyed.is_empty():
		$Destroyed.lib = library
		$Destroyed.motion_name = motions.destroyed[_motion_index].name
		$Destroyed.play()
	else:
		$Destroyed.lib = null
		$Destroyed.motion_name = ""
	$Fire.position = Vector2(attack_motion.firex, attack_motion.firey)


func attack() -> void:
	$StandBy.visible = false
	$Attack.visible = true
	$Destroyed.visible = false
	$Attack.set_cur_frame(0)
	$Attack.play()
	$Attack.set_loop(1)
	_attack_ended = false
	_attack_timer = motions.attack[_motion_index].at * $Attack.get_play_time()


func is_attacking() -> bool:
	return $Attack.visible and not _attack_ended


func destroy() -> void:
	set_destroyed()
	if $Destroyed.lib != null:
		_effect_exp = $Exp.create_instance()
		_effect_exp.fire_at(0.0, 0.0, 0.0)


func set_destroyed() -> void:
	$StandBy.visible = false
	$Attack.visible = false
	$Destroyed.visible = true


func update(delta: float) -> void:
	if _effect_fire != null:
		_effect_fire.update(delta)
		if not _effect_fire.is_live():
			_effect_fire.queue_free()
			_effect_fire = null
	if _effect_exp != null:
		_effect_exp.update(delta)
		if not _effect_exp.is_live():
			_effect_exp.queue_free()
			_effect_exp = null
	if $Attack.visible:
		if _attack_timer <= 0.0:
			if unit_index != 0:
				_effect_fire = $Fire.create_instance()
				if army_id != 0 or _motion_index <= 1:
					_effect_fire.effect_res = _effect_fire.effect_res.duplicate()
					_effect_fire.effect_res.asset = _effect_fire.effect_res.asset.duplicate()
					_effect_fire.effect_res.asset.name = motions.fireeffect
				_effect_fire.fire_at(0.0, 0.0, 0.0)
			match army_id:
				0:
					if _motion_index <= 1:
						g_SoundRes.play_char_se(SND_EFFECT.FIRE_WAV)
					else :
						g_SoundRes.play_char_se(SND_EFFECT.MACHINE_GUN_WAV)
				1:
					g_SoundRes.play_char_se(SND_EFFECT.MACHINE_GUN_WAV)
				2:
					g_SoundRes.play_char_se(SND_EFFECT.CANNON_WAV)
				3:
					g_SoundRes.play_char_se(SND_EFFECT.ROCKET_WAV)
				4:
					g_SoundRes.play_char_se(SND_EFFECT.CANNON_WAV)
				5:
					g_SoundRes.play_char_se(SND_EFFECT.CANNON_WAV)
				6:
					g_SoundRes.play_char_se(SND_EFFECT.NAVAL_GUN_WAV)
				7:
					g_SoundRes.play_char_se(SND_EFFECT.NAVAL_GUN_WAV)
				8:
					g_SoundRes.play_char_se(SND_EFFECT.NAVAL_GUN_WAV)
				16:
					g_SoundRes.play_char_se(SND_EFFECT.CANNON_WAV)
		if $Attack.update(delta):
			_attack_ended = true
	elif $Destroyed.visible:
		$Destroyed.shape_color.a  = max($Destroyed.shape_color.a - 1.5 * delta, 0.0)
		$Destroyed.update(delta)
