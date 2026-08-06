extends GUIElement

var _fade: float

func _process(delta: float) -> void:
	_fade += 2.5 * delta
	if _fade > 0.5:
		var a := 2.0 * (_fade - 0.5)
		$GUIElement/TextureRect.self_modulate = Color(a, a, a, a)
