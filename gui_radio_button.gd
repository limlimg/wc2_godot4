@tool
class_name GUIRadioButton
extends GUIButton

@export
var selected: bool:
	set(value):
		if value != selected:
			selected = value
			_on_render()


func _on_render():
	var color := Color.WHITE
	if selected:
		$TextureButton.toggle_mode = true
		$TextureButton.set_pressed_no_signal(true)
	else:
		$TextureButton.toggle_mode = false
		if not enable:
			color = Color8(120, 120, 120)
		else:
			if $TextureButton.button_pressed:
				color = Color8(210, 210, 210)
	color.a = alpha
	$TextureButton.self_modulate = color
