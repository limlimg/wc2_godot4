extends "res://app/src/main/cpp/native-lib.gd"

## .strings or .xml files to be used by this class should be imported as
## Translation.

var _translation: Translation

func load(file_name: String) -> bool:
	var path := get_path(file_name, "")
	_translation = load(path) as Translation
	if _translation == null:
		return false
	return true


func clear() -> void:
	_translation = null


func get_string(key: StringName) -> StringName:
	return _translation.get_message(key)
