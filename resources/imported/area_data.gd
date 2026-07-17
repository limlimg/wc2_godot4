class_name AreaData
extends Resource

@export_storage
var _mem: PackedByteArray

@export_storage
var _offset: int

@export
var area_rect: Rect2i:
	get():
		return Rect2i(
			_mem.decode_u32(_offset),
			_mem.decode_u32(_offset + 4),
			_mem.decode_u32(_offset + 8),
			_mem.decode_u32(_offset + 12))
	set(value):
		_mem.encode_u32(_offset, value.position.x)
		_mem.encode_u32(_offset + 4, value.position.y)
		_mem.encode_u32(_offset + 8, value.size.x)
		_mem.encode_u32(_offset + 12, value.size.y)


@export
var army_position: Vector2i:
	get():
		return Vector2i(
			_mem.decode_u32(_offset + 16),
			_mem.decode_u32(_offset + 20))
	set(value):
		_mem.encode_u32(_offset + 16, value.x)
		_mem.encode_u32(_offset + 20, value.y)


@export
var construction_position: Vector2i:
	get():
		return Vector2i(
			_mem.decode_u32(_offset + 24),
			_mem.decode_u32(_offset + 28))
	set(value):
		_mem.encode_u32(_offset + 24, value.x)
		_mem.encode_u32(_offset + 28, value.y)


@export
var installation_position: Vector2i:
	get():
		return Vector2i(
			_mem.decode_u32(_offset + 32),
			_mem.decode_u32(_offset + 36))
	set(value):
		_mem.encode_u32(_offset + 32, value.x)
		_mem.encode_u32(_offset + 36, value.y)


@export
var sea: int:
	get():
		return _mem.decode_u32(_offset + 40)
	set(value):
		_mem.encode_u32(_offset + 40, value)
