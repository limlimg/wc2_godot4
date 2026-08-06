class_name CFight

var attack_army_lost_dice: int
var defend_army_lost_dice: int
var can_counter: bool
var attack_index: int
var attack_army_second_attack: bool
var defend_army_second_attack: bool
var second_attack_side: int
var battle_started: bool

func first_attack(attack_area: int, defend_area: int) -> void:
	pass


func second_attack() -> void:
	pass


func apply_result() -> void:
	pass


func air_strikes_attack(start, target_area: int, action_type: int = 4) -> void:
	pass
