@tool
class_name AssetManager
extends ResourceFormatLoader

const _ASSETS_PATH = "res://app/src/main/assets/"

static var _instance: AssetManager

func _init() -> void:
	_instance = self


func _recognize_path(path: String, _type: StringName) -> bool:
	return not path.begins_with(_ASSETS_PATH)


func _exists(path: String) -> bool:
	return ResourceLoader.exists(_ASSETS_PATH + path)


func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	path = path.trim_prefix("res://")
	return ResourceLoader.load(_ASSETS_PATH + path, "", cache_mode)
