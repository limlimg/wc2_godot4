@tool
class_name GUIMedalButton
extends GUIButton

## Common base class for GUICommanderMedal and GUIWarMedal.

@export
var selected: bool:
	set(value):
		if value != selected:
			selected = value
			if value:
				$Medal/Arrow.visible = true
			else:
				$Medal/Arrow.visible = false


var _arrow_y: float

@export
var arrow_color := Color.WHITE:
	set = set_arrow_color

func set_arrow_color(value: Color) -> void:
	if value != arrow_color:
		arrow_color = value
		$Medal/Arrow.self_modulate = value


func _process(delta: float) -> void:
	var y := _arrow_y - 25.0 * delta
	while y < -10.0:
		y += 10.0
	_arrow_y = y
	y = -5.0 + absf(y + 5.0)
	if ecGraphics.instance().content_scale_size_mode == 3:
		$Medal/Arrow.position.y = y * 2
	else:
		$Medal/Arrow.position.y = y
