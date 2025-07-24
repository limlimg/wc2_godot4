@tool
extends Resource

## Change one of the properties and the other will change itself according to
## the color schema of CAreaMark.

const _CAreaMark = preload("res://app/src/main/cpp/c_area_mark.gd")

@export
var id: int:
	get():
		return _CAreaMark.color_to_id(color)
	set(value):
		color = _CAreaMark.id_to_color(value)


@export
var color: Color
