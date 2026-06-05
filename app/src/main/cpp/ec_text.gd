extends "res://app/src/main/cpp/gui_element.gd"

## Assign ecUniFont to Theme property.
##
## DrawText and GetStringWidth are not implemented because they do not fit the
## usage of this class in this project.

@export
var text: String:
	set = set_text

@export
var color: Color = Color.WHITE:
	set = set_color

@export
var text_position: Vector2:
	set(value):
		text_position = value
		if is_node_ready():
			_label.position = value


@export
var alignment: HorizontalAlignment:
	set(value):
		alignment = value
		if is_node_ready():
			_label.horizontal_alignment = value
			match value:
				HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT:
					_label.grow_horizontal = Control.GROW_DIRECTION_END
				HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT:
					_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
				_:
					_label.grow_horizontal = Control.GROW_DIRECTION_BOTH


@onready var _label: Label = $Label

func _ready() -> void:
	init()


func init():
	set_color(color)
	_draw_text()


func set_color(value: Color) -> void:
	color = value
	if is_node_ready():
		_label.remove_theme_color_override(&"font_color")
		_label.add_theme_color_override(&"font_color", value)


func _draw_text() -> void:
	text_position = text_position
	alignment = alignment


func set_text(value: String) -> void:
	text = value
	if is_node_ready():
		_label.text = value


func set_alpha(alpha: float)-> void:
	set_color(Color(color, alpha))


func get_height() -> float:
	if is_node_ready():
		return _label.size.y
	else:
		return 0.0


func get_num_lines() -> int:
	if is_node_ready():
		return _label.get_line_count()
	else:
		return 0
