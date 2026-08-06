extends Control

@export
var text: String:
	get = get_text,
	set = set_text

@export
var color: Color:
	get = get_color,
	set = set_color

func get_text() -> String:
	return $Label.text


func set_text(value: String) -> void:
	$Label.text = value


func get_color() -> Color:
	return $Label.self_modulate


func set_color(value: Color) -> void:
	$Label.self_modulate = value


func update(delta: float) -> bool:
	var a := maxf($Label.self_modulate.a - 0.5 * delta, 0.2)
	$Label.self_modulate.a = a
	var y = $Label.position - 40.0 * delta
	return not a <= 0.2
