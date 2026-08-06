class_name ecTexture
extends Resource

@export
var texture: Texture2D

@export
var size_override: Vector2

var res_scale := 1.0

var loading_path: String
var loading_scale: float

func complete_loading() -> void:
	if loading_path.is_empty():
		return
	texture = ResourceLoader.load_threaded_get(loading_path)
	size_override = texture.get_size() / loading_scale / res_scale
	loading_path = ""
