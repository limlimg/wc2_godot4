class_name SaveHeader
extends Resource

const _SaveCountryInfo = preload("res://app/src/main/cpp/save_country_info.gd")
const _SaveAreaInfo = preload("res://app/src/main/cpp/save_area_info.gd")
const _DialogueDef = preload("res://app/src/main/cpp/dialogue_def.gd")

@export_storage
var _mem: PackedByteArray

var game_mode: int:
	get():
		return _mem.decode_s32(8)
	set(value):
		_mem.encode_s32(8, value)


@export
var map: int:
	get():
		return _mem.decode_s32(16)
	set(value):
		_mem.encode_s32(16, value)


@export
var areas_enable: String:
	get():
		return _mem.slice(20, min(_mem.find(0, 20), 52)).get_string_from_utf8()
	set(value):
		var s := value.to_utf8_buffer()
		s.append(0)
		s.resize(32)
		_mem.encode_u32(20, s.decode_u32(0))
		_mem.encode_u32(24, s.decode_u32(4))
		_mem.encode_u32(28, s.decode_u32(8))
		_mem.encode_u32(32, s.decode_u32(12))
		_mem.encode_u32(36, s.decode_u32(16))
		_mem.encode_u32(40, s.decode_u32(20))
		_mem.encode_u32(44, s.decode_u32(24))
		_mem.encode_u32(48, s.decode_u32(28))


var player_country_name: Array[String]:
	get():
		return [
			_mem.slice(52, min(_mem.find(0, 52), 60)).get_string_from_utf8(),
			_mem.slice(60, min(_mem.find(0, 60), 68)).get_string_from_utf8(),
			_mem.slice(68, min(_mem.find(0, 68), 76)).get_string_from_utf8(),
			_mem.slice(76, min(_mem.find(0, 76), 84)).get_string_from_utf8()
		]
	set(value):
		for i in min(value.size(), 4):
			var s := value[i].to_utf8_buffer()
			s.append(0)
			s.resize(8)
			_mem.encode_u32(52 + 8 * i, s.decode_u32(0))
			_mem.encode_u32(56 + 8 * i, s.decode_u32(4))


var battle_file_name: String:
	get():
		return _mem.slice(84, min(_mem.find(0, 84), 116)).get_string_from_utf8()
	set(value):
		var s := value.to_utf8_buffer()
		s.append(0)
		s.resize(32)
		_mem.encode_u32(84, s.decode_u32(0))
		_mem.encode_u32(88, s.decode_u32(4))
		_mem.encode_u32(92, s.decode_u32(8))
		_mem.encode_u32(96, s.decode_u32(12))
		_mem.encode_u32(100, s.decode_u32(16))
		_mem.encode_u32(104, s.decode_u32(20))
		_mem.encode_u32(108, s.decode_u32(24))
		_mem.encode_u32(112, s.decode_u32(28))


var camera_x: float:
	get():
		return _mem.decode_float(116)
	set(value):
		_mem.encode_float(116, value)


var camera_y: float:
	get():
		return _mem.decode_float(120)
	set(value):
		_mem.encode_float(120, value)


var camera_scale: float:
	get():
		return _mem.decode_float(124)
	set(value):
		_mem.encode_float(124, value)


var current_country: int:
	get():
		return _mem.decode_u32(128)
	set(value):
		_mem.encode_u32(128, value)


var current_dialogue: int:
	get():
		return _mem.decode_u32(132)
	set(value):
		_mem.encode_u32(132, value)


var country_count: int:
	get():
		return _mem.decode_u32(136)
	set(value):
		_mem.encode_u32(136, value)


var area_count: int:
	get():
		return _mem.decode_u32(140)
	set(value):
		_mem.encode_u32(140, value)


var current_round: int:
	get():
		return _mem.decode_u32(144)
	set(value):
		_mem.encode_u32(144, value)


var random_reward_medal: int:
	get():
		return _mem.decode_u32(148)
	set(value):
		_mem.encode_u32(148, value)


var save_time_year: int:
	get():
		return _mem.decode_u32(152)
	set(value):
		_mem.encode_u32(152, value)


var save_time_month: int:
	get():
		return _mem.decode_u32(156)
	set(value):
		_mem.encode_u32(156, value)


var save_time_day: int:
	get():
		return _mem.decode_u32(160)
	set(value):
		_mem.encode_u32(160, value)


var save_time_hour: int:
	get():
		return _mem.decode_u32(164)
	set(value):
		_mem.encode_u32(164, value)


var save_time_min: int:
	get():
		return _mem.decode_u32(168)
	set(value):
		_mem.encode_u32(168, value)


var campaign: int:
	get():
		return _mem.decode_u32(172)
	set(value):
		_mem.encode_u32(172, value)


var battle: int:
	get():
		return _mem.decode_u32(176)
	set(value):
		_mem.encode_u32(176, value)


var victory: int:
	get():
		return _mem.decode_u32(180)
	set(value):
		_mem.encode_u32(180, value)


var great_victory: int:
	get():
		return _mem.decode_u32(184)
	set(value):
		_mem.encode_u32(184, value)


@export
var country: Array[_SaveCountryInfo]

@export
var area: Array[_SaveAreaInfo]

@export
var dialogue: Array[_DialogueDef]


func _init() -> void:
	_mem.resize(188)
