extends "res://app/src/main/cpp/gui_element.gd"

func _ready() -> void:
	init()


func init() -> void:
	modulate = Color.TRANSPARENT
	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)
