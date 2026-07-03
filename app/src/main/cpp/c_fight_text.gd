extends Control

@export
var text: String:
	get = get_text,
	set = set_text

@export
var color: Color:
	get = get_color,
	set = set_color

signal animation_finished

func get_text() -> String:
	return $Label.text


func set_text(value: String) -> void:
	$Label.text = value


func get_color() -> Color:
	return $Label.self_modulate


func set_color(value: Color) -> void:
	$Label.self_modulate = value


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	animation_finished.emit()
