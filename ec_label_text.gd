extends Control

@export
var font_name: String:
	set(value):
		if value != font_name:
			font_name = value
			init()


@export
var font_size: int:
	set(value):
		if value != font_size:
			font_size = value
			init()


@export
var alignment: HorizontalAlignment:
	set(value):
		if value != alignment:
			alignment = value
			init()


@export
var text: String:
	set = set_text

@export
var color: Color = Color.WHITE:
	set = set_color

@export
var alpha := 1.0:
	get = get_alpha,
	set = set_alpha

func init():
	color = Color.WHITE
	if not text.is_empty():
		$ecImage.texture = AppDelegate.ec_texture_with_string(text, font_name, font_size, alignment, size.x, size.y)


func set_text(value: String) -> void:
	if value != text:
		text = value
		if not value.is_empty():
			$ecImage.texture = AppDelegate.ec_texture_with_string(value, font_name, font_size, alignment, size.x, size.y)
		else:
			$ecImage.texture = null


func set_color(value: Color) -> void:
	if value != color:
		color = value
		$ecImage.set_color(value, -1)


func get_alpha() -> float:
	return color.a


func set_alpha(value: float) -> void:
	set_color(Color(color, value))


func draw_text(x: float, y: float) -> void:
	$ecImage.render(x, y)
