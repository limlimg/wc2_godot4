extends "res://app/src/main/cpp/gui_element.gd"

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
				$HBoxContainer.add_child($Prototype/GUIRect.duplicate())
			while $HBoxContainer.get_child_count() > n:
				var c := $HBoxContainer.get_child(0)
				$HBoxContainer.remove_child(c)
				c.queue_free()


func _on_touch(pos: Vector2, _index: int) -> void:
	value = clampi(floori(pos.x / size.x * max_value) + 1, 1, max_value)
