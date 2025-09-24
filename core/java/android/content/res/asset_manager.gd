@tool
class_name AssetManager
extends ResourceFormatLoader

const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _ASSETS_PATH = "res://app/src/main/assets/"

static var _instance: AssetManager

func _init() -> void:
	_instance = self


func _recognize_path(path: String, _type: StringName) -> bool:
	return not path.begins_with(_ASSETS_PATH)


func _exists(path: String) -> bool:
	return ResourceLoader.exists(_ASSETS_PATH + path.trim_prefix("res://"))


func _load(path: String, original_path: String, _use_sub_threads: bool, cache_mode: int) -> Variant:
	if not original_path.is_empty():
		path = original_path
	path = path.trim_prefix("res://")
	return ResourceLoader.load(_ASSETS_PATH + path, "", cache_mode)
