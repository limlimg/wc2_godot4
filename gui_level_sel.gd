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
			while _bars.size() < n:
				_bars.append($GUIElement/HBoxContainer/Prototype.duplicate())
				_bars[-1].visible = true
				$GUIElement/HBoxContainer.add_child(_bars[-1])
			while _bars.size() > n:
				_bars.pop_back().free()


var _bars: Array[Control]

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		value = clampi(floori(event.position.x / size.x * max_value) + 1, 1, max_value)
		accept_event()
