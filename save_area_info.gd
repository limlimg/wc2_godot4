class_name SaveAreaInfo
extends Resource

@export_storage
var _mem: PackedByteArray

@export_storage
var _offset: int

@export
var id: int:
	get():
		return _mem.decode_u32(_offset)
	set(value):
		_mem.encode_u32(_offset, value)


var country_index: int:
	get():
		return _mem.decode_u32(_offset + 4)
	set(value):
		_mem.encode_u32(_offset + 4, value)


var army_count: int:
	get():
		return _mem.decode_u32(_offset + 8)
	set(value):
		_mem.encode_u32(_offset + 8, value)


@export
var construction: int:
	get():
		return _mem.decode_u32(_offset + 12)
	set(value):
		_mem.encode_u32(_offset + 12, value)


@export
var level: int:
	get():
		return _mem.decode_u32(_offset + 16)
	set(value):
		_mem.encode_u32(_offset + 16, value)


@export
var installation: int:
	get():
		return _mem.decode_u32(_offset + 20)
	set(value):
		_mem.encode_u32(_offset + 20, value)


@export
var country: StringName

@export
var army: Array[SaveArmyInfo]:
	get():
		army_count = min(army.size(), 4)
		army.resize(army_count)
		for i in army_count:
			var x := army[i]
			x._mem = _mem
			x._offset = _offset + 24 + 44 * i
		return army
	set(value):
		army = value
		army_count = min(value.size(), 4)
		for i in army_count:
			if value[i]._mem != _mem or value[i]._offset != _offset + 24 + 44 * i:
				_mem.encode_u64(_offset + 24 + 44 * i, value[i]._mem.decode_u64(value[i]._offset))
				_mem.encode_u64(_offset + 32 + 44 * i, value[i]._mem.decode_u64(value[i]._offset + 8))
				_mem.encode_u64(_offset + 40 + 44 * i, value[i]._mem.decode_u64(value[i]._offset + 16))
				_mem.encode_u64(_offset + 48 + 44 * i, value[i]._mem.decode_u64(value[i]._offset + 24))
				_mem.encode_u64(_offset + 56 + 44 * i, value[i]._mem.decode_u64(value[i]._offset + 32))
				_mem.encode_u32(_offset + 64 + 44 * i, value[i]._mem.decode_u32(value[i]._offset + 40))


func _init() -> void:
	_mem.resize(200)
