extends Node

signal _global_layout

func add_on_global_layout_listener(listener: Callable) -> void:
	_global_layout.connect(listener)


func remove_on_global_layout_listener(victim: Callable) -> void:
	_global_layout.disconnect(victim)


func dispatch_on_global_layout() -> void:
	_global_layout.emit()
