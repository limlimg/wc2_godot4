extends GUIElement

@export
var _attack_area: int

@export
var _defend_area: int

var _battle_state: int
var _fight_state: int
var _second_attack_time: float
var _start_attack_time: float
var _fight := CFight.new()

func battle_start(attack_area: int, defend_area: int) -> void:
	_attack_area = attack_area
	_defend_area = defend_area
	# TODO: set stats
	_reset_battle()
	_fight.first_attack(_attack_area, _defend_area)
	_battle_state = 1
	_fight_state = 0


func _reset_battle() -> void:
	if _attack_area < 0 or _defend_area < 0:
		return
	var area1 = g_Scene.get_area(_attack_area)
	if area1 == null:
		return
	var area2 = g_Scene.get_area(_defend_area)
	if area2 == null:
		return
	var army1 = area1.get_army(0)
	var army2 = area2.get_army(0)
	var army1_other := CObjectDef.instance().get_army_def(army1.def.id, "others")
	var army2_other := CObjectDef.instance().get_army_def(army2.def.id, "others")
	$Left/CBattleScene.set_battle_area(_attack_area)
	$Right/CBattleScene.set_battle_area(_defend_area)
	$Left/Flag.texture = g_GameRes.get_flag_image("flag_{0}.png".format([area1.country.name]))
	$Right/Flag.texture = g_GameRes.get_flag_image("flag_{0}.png".format([area2.country.name]))
	$Left/MinAttack.text = "{0}".format([army1.def.minatk])
	$Left/MinAttack.color = Color.GREEN if army1.def.minatk > army1_other.minatk else Color.WHITE
	$Left/MaxAttack.text = "{0}".format([army1.def.maxatk])
	$Left/MaxAttack.color = Color.GREEN if army1.def.maxatk > army1_other.maxatk else Color.WHITE
	$Right/MinAttack.text = "{0}".format([army2.def.minatk])
	$Right/MinAttack.color = Color.GREEN if army2.def.minatk > army2_other.minatk else Color.WHITE
	$Right/MaxAttack.text = "{0}".format([army2.def.maxatk])
	$Right/MaxAttack.color = Color.GREEN if army2.def.maxatk > army2_other.maxatk else Color.WHITE
	$Left.position.x = -size.x / 2
	$Right.position.x = 3 * size.x / 2


func _process(delta: float) -> void:
	if _fight.battle_started:
		_fight.battle_started = false
	elif _battle_state != 0:
		$Left/CBattleScene.update(delta)
		$Right/CBattleScene.update(delta)
		var v := 2500.0 if ecGraphics.instance().content_scale_size_mode == 3 else 1000.0
		match _battle_state:
			1:
				var x := minf($Left.position.x + v * delta, 0.0)
				$Left.position.x = x
				$Right.position.x = size.x - x
				if x >= 0.0:
					_fight_state = 0
					_battle_state = 2
					_start_attack_time = 0.0
					_second_attack_time = 0.0
			2:
				_update_fighting(delta)
			3:
				var dest := -size.x / 2
				var x := maxf($Left.position.x - v * delta, dest)
				$Left.position.x = x
				$Right.position.x = size.x - x
				if x <= dest:
					_battle_state = 0
					hide()
					$Left/CBattleScene.clear_craters()
					$Right/CBattleScene.clear_craters()
					$Left/CBattleScene.clear_effect()
					$Right/CBattleScene.clear_effect()
					_fight.battle_started = false


func _update_fighting(delta: float) -> void:
	if _fight_state == 0:
		_start_attack_time += delta
		if _start_attack_time > 0.1:
			_fight_state = 1
			if _fight.attack_index == 0:
				$Left/CBattleScene.attack()
				if _fight.can_counter:
					$Right/CBattleScene.attack()
			else:
				if _fight.second_attack_side == 0:
					$Left/CBattleScene.attack()
				else:
					$Right/CBattleScene.attack()
	else:
		if $Left/CBattleScene.is_attacking() or $Right/CBattleScene.is_attacking():
			if _fight_state != 2:
				return
		else:
			if _fight_state == 1:
				$Left/CBattleScene.destroy_units(_fight.attack_army_lost_dice)
				$Right/CBattleScene.destroy_units(_fight.defend_army_lost_dice)
			_fight_state = 2
			_second_attack_time += delta
			if _second_attack_time > 1.5:
				_fight.apply_result()
				if _fight.attack_army_second_attack or _fight.defend_army_second_attack:
					_fight.second_attack()
					_start_attack_time = 0.0
					_fight_state = 0
					_second_attack_time = 0.0
				else:
					_battle_finish()


func _battle_finish() -> void:
	_battle_state = 3


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
