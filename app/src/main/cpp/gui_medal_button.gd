extends "res://app/src/main/cpp/gui_button.gd"

## Common base class for GUICommanderMedal and GUIWarMedal.

@export
var selected: bool:
	set(value):
		if value != selected:
			selected = value
			if value:
				$Medal/GUIRect/Control/Arrow.visible = true
				$AnimationPlayer.play("arrow")
			else:
				$Medal/GUIRect/Control/Arrow.visible = false
				$AnimationPlayer.stop()



@export
var arrow_color := Color.WHITE:
	set = set_arrow_color


func set_arrow_color(value: Color) -> void:
	if value != arrow_color:
		arrow_color = value
		$Medal/GUIRect/Control/Arrow.self_modulate = value
