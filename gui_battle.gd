extends GUIElement

@export
var attack_area: int

@export
var defend_area: int

var _fight: CFight
var _tween: Tween

func battle_start() -> void:
	_reset_battle()
	_fight.first_attack(attack_area, defend_area)
	$AnimationPlayer.play(&"move_in")
	var anim_name: StringName = await $AnimationPlayer.animation_finished
	if anim_name == &"move_in":
		if _tween != null:
			_tween.kill()
		_tween.tween_interval(0.1)
		_tween.tween_callback(func ():
			$Left/CBattleScene.attack()
			if _fight.can_counter:
				$Right/CBattleScene.attack()
				$Right/CBattleScene.attack_completed.connect(_on_battle_scene_attack_completed, CONNECT_ONE_SHOT)
			await $Left/CBattleScene.attack_completed
			_on_battle_scene_attack_completed())
		_tween_second_attack()


func _reset_battle() -> void:
	if attack_area < 0 or defend_area < 0:
		return
	var area1 := AppDelegate.g_Scene.get_area(attack_area)
	if area1 == null:
		return
	var area2 := AppDelegate.g_Scene.get_area(defend_area)
	if area2 == null:
		return
	var army1 := area1.get_army(0)
	var army2 := area2.get_army(0)
	var army1_other := CObjectDef.instance().get_army_def(army1.def.id, "others")
	var army2_other := CObjectDef.instance().get_army_def(army2.def.id, "others")
	$Left/CBattleScene.set_battle_area(attack_area)
	$Right/CBattleScene.set_battle_area(defend_area)
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
	$AnimationPlayer.play(&"RESET")


func _tween_second_attack() -> void:
	_tween.tween_interval(1.5)
	_tween.tween_callback(func ():
		_fight.apply_result()
		if _fight.attack_army_second_attack or _fight.defend_army_second_attack:
			_fight.second_attack()
			_tween.tween_interval(0.1)
			_tween.tween_callback(func ():
				if _fight.second_attack_side == 0:
					$Left/CBattleScene.attack()
					await $Left/CBattleScene.attack_completed
					_on_battle_scene_attack_completed()
				else:
					$Right/CBattleScene.attack()
					await $Right/CBattleScene.attack_completed
					_on_battle_scene_attack_completed())
			_tween_second_attack()
		else:
			_battle_finish())


func _on_battle_scene_attack_completed() -> void:
	if not $Left/CBattleScene.is_attacking() and not $Right/CBattleScene.is_attacking():
		$Left/CBattleScene.destroy_units(_fight.attack_army_lost_dice)
		$Right/CBattleScene.destroy_units(_fight.defend_army_lost_dice)


func _battle_finish() -> void:
	$AnimationPlayer.play("move_out")
	var anim_name: StringName = await $AnimationPlayer.animation_finished
	if anim_name == &"move_out":
		hide()
		$Left/CBattleScene.clear_craters()
		$Right/CBattleScene.clear_craters()
		$Left/CBattleScene.clear_effect()
		$Right/CBattleScene.clear_effect()
