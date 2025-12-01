extends Node

const _AssetManager = preload("res://core/java/android/content/res/asset_manager.gd")

func get_assets() -> _AssetManager:
	return _AssetManager._instance
