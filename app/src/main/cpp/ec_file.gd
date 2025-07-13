
## Part of the original code can open zip files and thereby check the integrity
## of game files. They are unsused in the original code and not ported.

var _is_resource := true
var _resource: Resource
var _file: FileAccess

func is_file_exist(path: String) -> bool:
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)


func open(path: String, flags: FileAccess.ModeFlags) -> RefCounted:
	if path == "":
		return null
	if ResourceLoader.exists(path):
		_is_resource = true
		_resource = load(path)
		return _resource
	else:
		_is_resource = false
		_file = FileAccess.open(path, flags)
		return _file


func close() -> void:
	if _is_resource:
		_resource = null
	else:
		if _file != null:
			_file.close()
			_file = null


func get_size() -> int:
	if _is_resource:
		return 0
	else:
		if _file != null:
			return _file.get_length()
		else:
			return 0


func get_cur_pos() -> int:
	if _is_resource:
		return 0
	else:
		if _file != null:
			return _file.get_position()
		else:
			return 0


func seek(position: int, whence: int) -> bool:
	if _is_resource:
		return false
	else:
		if _file != null:
			if whence == 0:
				_file.seek(position)
				return true
			elif whence == 1:
				_file.seek(_file.get_position() + position)
				return true
			elif whence == 2:
				_file.seek_end(-position)
				return true
			else:
				return false
		else:
			return false


func read(buffer: PackedByteArray, length: int) -> bool:
	if _is_resource:
		return false
	else:
		if _file != null:
			var read_buffer := _file.get_buffer(length)
			buffer.append_array(read_buffer)
			return read_buffer.size() <= length
		else:
			return false


func write(buffer: PackedByteArray, length: int) -> bool:
	if _file == null:
		return false
	return _file.store_buffer(buffer.slice(0, length))
