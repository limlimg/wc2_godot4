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


@export
var spacing: Vector2i:
	set(value):
		if value != spacing:
			spacing = value
			$Label.remove_theme_constant_override(&"line_spacing")
			$Label.add_theme_constant_override(&"line_spacing", spacing.y)
			$Label.remove_theme_font_override(&"font")
			if spacing.x != 0.0:
				var font := FontVariation.new()
				font.base_font = theme.default_font
				font.spacing_glyph = spacing.x
				$Label.add_theme_font_override(&"font", font)


@export
var fit_minimun_size: bool:
	set(value):
		if value != fit_minimun_size:
			fit_minimun_size = value
			update_minimum_size()


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
	update_minimum_size()


func _get_minimum_size() -> Vector2:
	if fit_minimun_size:
		return $Label.size
	else:
		return Vector2.ZERO


func set_alpha(alpha: float)-> void:
	set_color(Color(color, alpha))


func get_height() -> float:
	return $Label.size.y


func get_num_lines() -> int:
	return $Label.get_line_count()
