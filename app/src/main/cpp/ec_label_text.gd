extends Control

const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")

@export
var font_name: String:
	set(value):
		if value != font_name:
			font_name = value
			init()


@export
var font_size_ipad: int:
	set(value):
		if value != font_size_ipad:
			font_size_ipad = value
			init()


@export
var font_size: int:
	set(value):
		if value != font_size:
			font_size = value
			init()


@export
var alignement: HorizontalAlignment:
	get():
		return $Label.horizontal_alignment
	set(value):
		$Label.horizontal_alignment = value


@export
var text: String:
	get = get_text,
	set = set_text

@export
var color: Color = Color.WHITE:
	get = get_color,
	set = set_color

func init() -> void:
	$Label.remove_theme_font_override(&"font")
	$Label.remove_theme_font_size_override(&"font_size")
	var font := SystemFont.new()
	font.font_names = [font_name]
	$Label.add_theme_font_override(&"font", font)
	if _ecGraphics.instance().content_scale_size_mode == 3:
		$Label.add_theme_font_size_override(&"font_size", font_size_ipad)
	else:
		$Label.add_theme_font_size_override(&"font_size", font_size)


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
