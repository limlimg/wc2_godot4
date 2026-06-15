extends "res://app/src/main/cpp/gui_element.gd"

## Assign ecUniFont to Theme property.
##
## DrawText and GetStringWidth are not implemented because they do not fit the
## usage of this class in this project.

@export
var text: String:
	get = get_text,
	set = set_text

@export
var color: Color = Color.WHITE:
	get = get_color,
	set = set_color

@export
var text_position: Vector2:
	get():
		return $Label.position
	set(value):
		$Label.position = value


@export
var alignment: HorizontalAlignment:
	get():
		return $Label.horizontal_alignment
	set(value):
		alignment = value
		$Label.horizontal_alignment = value
		match value:
			HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT:
				$Label.grow_horizontal = Control.GROW_DIRECTION_END
			HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT:
				$Label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
			_:
				$Label.grow_horizontal = Control.GROW_DIRECTION_BOTH


func _ready() -> void:
	init()


func init():
	set_color(color)


func get_color() -> Color:
	return $Label.get_theme_color(&"font_color")


func set_color(value: Color) -> void:
	$Label.remove_theme_color_override(&"font_color")
	$Label.add_theme_color_override(&"font_color", value)


func get_text() -> String:
	return $Label.text


func set_text(value: String) -> void:
	$Label.text = value


func set_alpha(alpha: float)-> void:
	set_color(Color(color, alpha))


func get_height() -> float:
	return $Label.size.y


func get_num_lines() -> int:
	return $Label.get_line_count()
