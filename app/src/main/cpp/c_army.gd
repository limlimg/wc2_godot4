extends Resource

const _lib = preload("res://app/src/main/cpp/native-lib.gd")
const _ArmyDef = preload("res://app/src/main/cpp/army_def.gd")
const _CCountry = preload("res://app/src/main/cpp/c_country.gd")
const _SndEffect = preload("res://app/src/main/cpp/snd_effect.gd").SND_EFFECT
const _SaveArmyInfo = preload("res://app/src/main/cpp/save_army_info.gd")

const _EXP_REQUIREMENT = [100, 150, 200, 250]

var def: _ArmyDef:
	set(value):
		if value != def:
			def = value
			init()


var country: _CCountry:
	set(value):
		if value != country:
			country = value
			init()


var strength: int
var max_strength: int
var movement: int
var cards: int
var level: int
var _exp: int
var _morale: int:
	set = set_morale

var _morale_up_round: int
var _direction: float
var _ai_active: bool

func init() -> void:
	if def == null or country == null:
		return
	strength = def.strength
	max_strength = def.strength
	movement = def.movement
	cards = 0
	level = 0
	_direction = 1.0
	_exp = 0
	_morale = 0
	_morale_up_round = 0
	_ai_active = false
	reset_max_strength(false)


func reset_max_strength(keep_absolute: bool) -> void:
	if country == null:
		return
	var buff := 0
	if cards & (1<<3) != 0:
		buff = _lib.get_commander_ability(country.get_commander_level())[4]
	buff = maxi(_lib.get_army_ability(level)[4], buff)
	@warning_ignore("integer_division")
	var new_max_strength = def.strength * (buff + 100) / 100
	if not keep_absolute:
		@warning_ignore("integer_division")
		strength = strength * new_max_strength / max_strength
	max_strength = new_max_strength
	strength = mini(strength, max_strength)


func get_num_dices() -> int:
	@warning_ignore("integer_division")
	var x := strength * 100 / get_max_strength()
	if x > 50:
		return 5
	elif x > 25:
		return 4
	elif x > 15:
		return 3
	elif x > 5:
		return 2
	else:
		return 1


func get_num_dices_if_lost_strength(value: int) -> int:
	@warning_ignore("integer_division")
	var x := (strength - value) * 100 / get_max_strength()
	if x > 50:
		return 5
	elif x > 25:
		return 4
	elif x > 15:
		return 3
	elif x > 5:
		return 2
	else:
		return 1


func lost_strength(value: int) -> bool:
	strength -= value
	if strength > 0:
		return false
	else:
		strength = 0
		return true


func poisoning() -> void:
	if strength > 1:
		strength /= 2


func add_exp(value: int) -> bool:
	if level > 3:
		return false
	_exp += value
	var next_exp = _EXP_REQUIREMENT[level]
	if is_navy():
		next_exp = next_exp * 3 / 2
	if _exp > next_exp:
		_exp -= next_exp
		upgrade()
		g_SoundRes.play_char_se(_SndEffect.LV_UP_WAV)
		return true
	else:
		return false


func is_navy() -> bool:
	return def.id >= 6 and def.id <= 9


func upgrade() -> void:
	if level >= 4:
		return
	level += 1
	add_strength(_lib.get_army_ability(level)[3])
	reset_max_strength(false)


func add_strength(value: int) -> void:
	strength = min(strength + value, get_max_strength())


func get_max_strength() -> int:
	return max_strength


func set_morale(value: int) -> void:
	_morale = value
	if _morale != 2:
		_morale_up_round = 0


func break_through() -> void:
	_morale = 2
	_morale_up_round = 2


func save_army(save: _SaveArmyInfo) -> void:
	save.type = def.id
	save.strength = strength
	save.movement = movement
	save.cards = cards
	save.max_strength = max_strength
	save.level = level
	save.experience = _exp
	save.morale = _morale
	save.morale_up_round = _morale_up_round
	save.direction = _direction
	save.ai_active = _ai_active


func load_army(save: _SaveArmyInfo) -> void:
	strength = save.strength
	movement = maxi(save.movement, 0)
	cards = save.cards
	max_strength = save.max_strength
	level = save.level
	_exp = save.experience
	_morale = save.morale
	_morale_up_round = save.morale_up_round
	_direction = save.direction
	_ai_active = save.ai_active
	reset_max_strength(false)


func turn_begin() -> void:
	movement = def.movement
	_ai_active = true


func turn_end() -> void:
	movement = 0
	_ai_active = false
	if _morale_up_round > 0:
		_morale_up_round -= 1
		if _morale_up_round == 0:
			_morale = 0
