
## In the original game code, ecFile wraps the difference between assets files
## and save files which are accessed by AAssetManager and C FILE* respectively.
## It is involved in accessing all assets and save files.
##
## In this Godot port, all assets files except .bin files are imported as
## Resource. This detects format errors (e.g a tag mismatch in an .xml file)
## in the editor and speed up their loading during runtime. The loading and
## usage of Resource is too different and, as a result, they are not wrapped in
## this class. The following functions and classes are affected: GetPath,
## ecTextureLoad, ecUniFont, TiXMLDocument and CAreaMark.
## 
## Part of the original code can open zip files and thereby check the integrity
## of game files. They are unsused in the original code and not implemented.

var _is_assets := true
var _file: FileAccess

func is_file_exist(path: String) -> bool:
	return FileAccess.file_exists(path)


func open(path: String, flags: FileAccess.ModeFlags) -> bool:
	if path == "":
		return false
	if path.begins_with("res://"):
		_is_assets = true
		_file = FileAccess.open(path, FileAccess.READ)
	else:
		_is_assets = false
		_file = FileAccess.open(path, flags)
	return true


func close() -> void:
	if _file != null:
		_file.close()
		_file = null


func get_size() -> int:
	if _file != null:
		return _file.get_length()
	else:
		return 0


func get_cur_pos() -> int:
	if _file != null:
		return _file.get_position()
	else:
		return 0


func seek(position: int, whence: int) -> bool:
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
	if _file != null:
		var read_buffer := _file.get_buffer(length)
		buffer.append_array(read_buffer)
		return read_buffer.size() <= length
	else:
		return false


func write(buffer: PackedByteArray, length: int) -> bool:
	if _file == null or _is_assets:
		return false
	return _file.store_buffer(buffer.slice(0, length))
