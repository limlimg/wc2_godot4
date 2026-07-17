extends Node2D

signal animation_finished

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	animation_finished.emit()
