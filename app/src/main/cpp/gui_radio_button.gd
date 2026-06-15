@tool
extends "res://app/src/main/cpp/gui_button.gd"

@export
var selected: bool:
	set(value):
		if value != selected:
			selected = value
			if is_node_ready():
				_on_render()


func _on_render():
	var color := Color.WHITE
	if selected:
		_texture_button.toggle_mode = true
		_texture_button.set_pressed_no_signal(true)
	else:
		_texture_button.toggle_mode = false
		if not enable:
			color = Color8(120, 120, 120)
		else:
			if _texture_button.button_pressed:
				color = Color8(210, 210, 210)
	color.a = alpha
	_texture_button.self_modulate = color
	$ecText.alignment = HORIZONTAL_ALIGNMENT_CENTER
