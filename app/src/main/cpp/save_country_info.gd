class_name SaveCountryInfo
extends Resource

@export_storage
var _mem: PackedByteArray

@export_storage
var _offset := 0

@export
var money: int:
	get():
		return _mem.decode_u32(_offset)
	set(value):
		_mem.encode_u32(_offset, value)


@export
var industry: int:
	get():
		return _mem.decode_u32(_offset + 4)
	set(value):
		_mem.encode_u32(_offset + 4, value)


@export
var techlevel: int:
	get():
		return _mem.decode_u32(_offset + 8)
	set(value):
		_mem.encode_u32(_offset + 8, value)


var research_round: int:
	get():
		return _mem.decode_u32(_offset + 12)
	set(value):
		_mem.encode_u32(_offset + 12, value)


@export
var ai: bool:
	get():
		return _mem.decode_u8(_offset + 16) != 0
	set(value):
		_mem.encode_u8(_offset + 16, 1 if value else 0)


@export
var alliance: int:
	get():
		return _mem.decode_u32(_offset + 20)
	set(value):
		_mem.encode_u32(_offset + 20, value)


@export
var defeated: int:
	get():
		return _mem.decode_u32(_offset + 24)
	set(value):
		_mem.encode_u32(_offset + 24, value)


var cards_round: PackedInt32Array:
	get():
		return _mem.slice(_offset + 28, _offset + 140).to_int32_array()
	set(value):
		for i in min(value.size(), _offset + 28):
			_mem.encode_s32(_offset + 28 + 4 * i, value[i])


@export
var id: StringName:
	get():
		return _mem.slice(_offset + 140, min(_mem.find(0, _offset + 140), _offset + 156)).get_string_from_utf8()
	set(value):
		var s := value.to_utf8_buffer()
		s.append(0)
		s.resize(16)
		_mem.encode_u32(_offset + 140, s.decode_u32(0))
		_mem.encode_u32(_offset + 144, s.decode_u32(4))
		_mem.encode_u32(_offset + 148, s.decode_u32(8))
		_mem.encode_u32(_offset + 152, s.decode_u32(12))


@export
var name: StringName:
	get():
		return _mem.slice(_offset + 156, min(_mem.find(0, _offset + 156), _offset + 172)).get_string_from_utf8()
	set(value):
		var s := value.to_utf8_buffer()
		s.append(0)
		s.resize(16)
		_mem.encode_u32(_offset + 156, s.decode_u32(0))
		_mem.encode_u32(_offset + 160, s.decode_u32(4))
		_mem.encode_u32(_offset + 164, s.decode_u32(8))
		_mem.encode_u32(_offset + 168, s.decode_u32(12))


@export
var color: Color:
	get():
		return Color8(
			_mem.decode_u8(_offset + 172),
			_mem.decode_u8(_offset + 173),
			_mem.decode_u8(_offset + 174),
			_mem.decode_u8(_offset + 175)
		)
	set(value):
		_mem.encode_u8(_offset + 172, value.r8)
		_mem.encode_u8(_offset + 173, value.g8)
		_mem.encode_u8(_offset + 174, value.b8)
		_mem.encode_u8(_offset + 175, value.a8)


@export
var tax_factor: float:
	get():
		return _mem.decode_float(_offset + 176)
	set(value):
		_mem.encode_float(_offset + 176, value)


var enemies_destroyed: PackedInt32Array:
	get():
		return _mem.slice(_offset + 180, _offset + 220).to_int32_array()
	set(value):
		for i in min(value.size, 10):
			_mem.encode_s32(_offset + 180 + 4 * i, value[i])


var war_medal: PackedInt32Array:
	get():
		return _mem.slice(_offset + 220, _offset + 244).to_int32_array()
	set(value):
		for i in min(value.size(), 6):
			_mem.encode_s32(_offset + 220 + 4 * i, value[i])


@export
var commander: StringName:
	get():
		return _mem.slice(_offset + 244, min(_mem.find(0, _offset + 244), _offset + 268)).get_string_from_utf8()
	set(value):
		var s := value.to_utf8_buffer()
		s.append(0)
		s.resize(24)
		_mem.encode_u32(_offset + 244, s.decode_u32(0))
		_mem.encode_u32(_offset + 248, s.decode_u32(4))
		_mem.encode_u32(_offset + 252, s.decode_u32(8))
		_mem.encode_u32(_offset + 256, s.decode_u32(12))
		_mem.encode_u32(_offset + 260, s.decode_u32(16))
		_mem.encode_u32(_offset + 264, s.decode_u32(20))


var commander_round: int:
	get():
		return _mem.decode_u32(_offset + 268)
	set(value):
		_mem.encode_u32(_offset + 268, value)


var commander_alive: bool:
	get():
		return _mem.decode_u8(_offset + 272) != 0
	set(value):
		_mem.encode_u8(_offset + 272, 1 if value else 0)


var borrowed_loan: bool:
	get():
		return _mem.decode_u8(_offset + 273) != 0
	set(value):
		_mem.encode_u8(_offset + 273, 1 if value else 0)


var is_defeated: bool:
	get():
		return _mem.decode_u8(_offset + 274) != 0
	set(value):
		_mem.encode_u8(_offset + 274, 1 if value else 0)


func _init() -> void:
	_mem.resize(276)
