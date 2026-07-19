@tool
extends Resource

## Change one of the properties and the other will change itself according to
## the color schema of CAreaMark.

@export
var id: int:
	get():
		return CAreaMark.color_to_id(color)
	set(value):
		color = CAreaMark.id_to_color(value)


@export
var color: Color
