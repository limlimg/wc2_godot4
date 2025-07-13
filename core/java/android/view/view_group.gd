extends "res://core/java/android/view/view.gd"

const _View = preload("res://core/java/android/view/view.gd")

func add_view(child: _View) -> void:
	add_child(child)
