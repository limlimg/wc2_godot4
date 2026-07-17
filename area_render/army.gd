extends Node2D

@export
var country: String:
	get():
		return $Army.country
	set(value):
		$Army.country = value
		if _ai_medal != null:
			_ai_medal.country = value


@export
var alliance: int:
	get():
		return $Army.alliance
	set(value):
		$Army.alliance = value
		if _ai_medal != null:
			_ai_medal.common = value


@export
var stack: int:
	get():
		return $Army.stack
	set(value):
		$Army.stack = value
		$Army/ArmyInfo.stack = value
		if _ai_medal != null:
			_ai_medal.stack = value
		if _medal != null:
			_medal.stack = value


@export
var id: int:
	get():
		return $Army.id
	set(value):
		$Army.id = value


@export
var is_navy: bool:
	set(value):
		if value != is_navy:
			is_navy = value
			_set_sea_offset()


@export
var sea: bool:
	get():
		return $Army.sea
	set(value):
		$Army.sea = value
		_set_sea_offset()


@export
var direction: float:
	get():
		return $Army.direction
	set(value):
		$Army.direction = value


@export
var strength: int:
	get():
		return $Army/ArmyInfo.strength
	set(value):
		$Army/ArmyInfo.strength = value


@export
var max_strength: int:
	get():
		return $Army/ArmyInfo.max_strength
	set(value):
		$Army/ArmyInfo.max_strength = value


@export
var movement: int:
	get():
		return $Army/ArmyInfo.movement
	set(value):
		$Army/ArmyInfo.movement = value
		_set_morale_color()


@export
var cards: int:
	get():
		return $Army/ArmyInfo.cards
	set(value):
		$Army/ArmyInfo.cards = value
		_set_medal_visibility()


@export
var level: int:
	get():
		return $Army/ArmyInfo.cards
	set(value):
		$Army/ArmyInfo.cards = value


@export
var commander_level: int:
	set(value):
		if value != commander_level:
			commander_level = value
			if _medal != null:
				_medal.commander_level = value


@export
var morale: int:
	set(value):
		if value != morale:
			morale = value
			_set_morale_color()


@export
var ai: bool:
	set(value):
		if value != ai:
			ai = value
			_set_medal_visibility()


var _ai_medal: Node2D
var _medal: Node2D

func _set_morale_color() -> void:
	if movement > 0:
		match morale:
			1:
				$Army.morale_color = Color.from_rgba8(0xFF, 0x40, 0x40)
			2:
				$Army.morale_color = Color.from_rgba8(0x40, 0x40, 0xFF)
			_:
				$Army.morale_color = Color.WHITE
	else:
		match morale:
			1:
				$Army.morale_color = Color.from_rgba8(0xC0, 0x40, 0x40)
			2:
				$Army.morale_color = Color.from_rgba8(0x40, 0x40, 0xC0)
			_:
				$Army.morale_color = Color.from_rgba8(0xC0, 0xC0, 0xC0)


func _set_sea_offset() -> void:
	var y := 0.0
	if is_navy:
		y += 8.0
	if sea and cards & (1<<2) != 0:
		y += 4.0
	$Army/ArmyInfo.position.y = y


func _set_medal_visibility() -> void:
	if cards & (1<<3) != 0:
		if ai:
			if _ai_medal == null:
				_ai_medal = $Army/ArmyInfo/AICommanderMedal.create_instance()
				_ai_medal.stack = stack
				_ai_medal.country = country
				_ai_medal.common = alliance
			if _medal != null:
				_medal.queue_free()
				_medal = null
		else:
			if _ai_medal != null:
				_ai_medal.queue_free()
				_ai_medal = null
			if _medal == null:
				_medal = $Army/ArmyInfo/CommanderMedal.create_instance()
				_medal.stack = stack
				_medal.commander_level = commander_level
	else:
		if _ai_medal != null:
			_ai_medal.queue_free()
			_ai_medal = null
		if _medal != null:
			_medal.queue_free()
			_medal = null
