extends GUIElement

@export
var enable := true

@export
var max_value: int

@export
var value: int:
	set(n):
		if n != value:
			value = n
			while $HBoxContainer.get_child_count() < n:
				_bars.append($Prototype/GUIElement.duplicate())
				$HBoxContainer.add_child(_bars[-1])
			while $HBoxContainer.get_child_count() > n:
				_bars.pop_back().free()


var _bars: Array[Control]

func _on_touch(pos: Vector2, _index: int) -> void:
	value = clampi(floori(pos.x / size.x * max_value) + 1, 1, max_value)
