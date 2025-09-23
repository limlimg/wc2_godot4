extends "res://app/src/main/cpp/native-lib.gd"

## .strings or .xml files to be used by this class should be imported as
## Translation.

var _translation: Translation

func load(file_name: String) -> bool:
	var path := get_path(file_name, "")
	_translation = load(path) as Translation
	if _translation == null:
		return false
	if self == g_string_table:
		TranslationServer.add_translation(_translation)
	return true


func clear() -> void:
	_translation = null
	if self == g_string_table:
		TranslationServer.remove_translation(_translation)


func get_string(key: StringName) -> StringName:
	return _translation.get_message(key)
