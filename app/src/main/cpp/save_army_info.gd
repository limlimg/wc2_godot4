class_name SaveArmyInfo
extends Resource

@export_storage
var _mem: PackedByteArray

@export_storage
var _offset := 0

@export
var type: int:
	get():
		return _mem.decode_u32(_offset)
	set(value):
		_mem.encode_u32(_offset, value)


var durability: int:
	get():
		return _mem.decode_u32(_offset + 4)
	set(value):
		_mem.encode_u32(_offset + 4, value)


var movement: int:
	get():
		return _mem.decode_u32(_offset + 8)
	set(value):
		_mem.encode_u32(_offset + 8, value)


@export
var cards: int:
	get():
		return _mem.decode_u32(_offset + 12)
	set(value):
		_mem.encode_u32(_offset + 12, value)


var max_durability: int:
	get():
		return _mem.decode_u32(_offset + 16)
	set(value):
		_mem.encode_u32(_offset + 16, value)


@export
var level: int:
	get():
		return _mem.decode_u32(_offset + 20)
	set(value):
		_mem.encode_u32(_offset + 20, value)


var experience: int:
	get():
		return _mem.decode_u32(_offset + 24)
	set(value):
		_mem.encode_u32(_offset + 24, value)


var morale: int:
	get():
		return _mem.decode_u32(_offset + 28)
	set(value):
		_mem.encode_u32(_offset + 28, value)


var moraleUpRound: int:
	get():
		return _mem.decode_u32(_offset + 32)
	set(value):
		_mem.encode_u32(_offset + 32, value)


var direction: float:
	get():
		return _mem.decode_float(_offset + 36)
	set(value):
		_mem.encode_float(_offset + 36, value)


var ai_active: bool:
	get():
		return _mem.decode_u8(_offset + 40) != 0
	set(value):
		_mem.encode_u8(_offset + 40, 1 if value else 0)


func _init() -> void:
	_mem.resize(44)
