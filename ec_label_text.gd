@tool
extends Control

@export
var font_name: String:
	set(value):
		if value != font_name:
			font_name = value
			_font.font_names = [value]
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
var alpha: float:
	get = get_alpha,
	set = set_alpha

var _text_paragraph := TextParagraph.new()
var _font := SystemFont.new()

func init():
	_text_paragraph.clear()
	match alignment:
		HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT:
			_text_paragraph.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER:
			_text_paragraph.alignment = HORIZONTAL_ALIGNMENT_CENTER
		_:
			_text_paragraph.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_text_paragraph.width = size.y
	if not text.is_empty():
		@warning_ignore("integer_division")
		_text_paragraph.add_string(text, _font, font_size)
	queue_redraw()


func set_text(value: String) -> void:
	if value != text:
		text = value
		init()


func set_color(value: Color) -> void:
	if value != color:
		color = value
		queue_redraw()


func get_alpha() -> float:
	return color.a


func set_alpha(value: float) -> void:
	set_color(Color(color, value))


func draw_text(x: float, y: float) -> void:
	ecGraphics.instance().render_text(_text_paragraph, x, y, color)


func _draw() -> void:
	ecGraphics.instance().render_begin(self)
	draw_text(0.0, 0.0)
	ecGraphics.instance().render_end()
