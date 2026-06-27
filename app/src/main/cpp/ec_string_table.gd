extends "res://app/src/main/cpp/native-lib.gd"

## .strings or .xml files to be used by this class should be imported as
## Translation.

var _translation: Translation

func load_table(file_name: String) -> bool:
	var path := get_asset_path(file_name, "")
	if path.is_empty():
		return false
	_translation = load(path) as Translation
	if _translation == null:
		return false
	if self == g_StringTable:
		TranslationServer.add_translation(_translation)
	return true


func clear() -> void:
	_translation = null
	if self == g_StringTable:
		TranslationServer.remove_translation(_translation)


func get_string(key: StringName) -> StringName:
	return _translation.get_message(key)
