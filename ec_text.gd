@tool
extends Node2D

@export
var font: ecUniFont:
	set(value):
		if value != font:
			if font != null:
				font.changed.disconnect(init)
			font = value
			init()
			if value != null:
				value.changed.connect(init)


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


@export
var alignment: HorizontalAlignment:
	set(value):
		if value != alignment:
			alignment = value
			queue_redraw()


@export
var spacing: Vector2i:
	set(value):
		if value != spacing:
			spacing = value
			queue_redraw()


var _text_paragraph := TextParagraph.new()
var _font_with_spacing: FontVariation

func init():
	_text_paragraph.clear()
	if font == null or font.default_font == null:
		return
	if spacing != Vector2i.ZERO:
		if _font_with_spacing == null:
			_font_with_spacing = FontVariation.new()
			_font_with_spacing.base_font = font.default_font
		_font_with_spacing.spacing_glyph = spacing.x
		_font_with_spacing.spacing_bottom = spacing.y
		_text_paragraph.add_string(text, _font_with_spacing, font.default_font_size)
	else:
		_text_paragraph.add_string(text, font.default_font, font.default_font_size)
	if _font_with_spacing != null:
		_font_with_spacing.base_font = font.default_font
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


func get_height() -> float:
	return _text_paragraph.get_size().y


func get_string_width(line: int, max_remaining: bool) -> float:
	var num_lines = get_num_lines()
	var width := 0.0
	while line < num_lines:
		var next_width := _text_paragraph.get_line_width(line)
		if next_width > width:
			width = next_width
		if not max_remaining:
			break
		line += 1
	return width


func get_num_lines() -> int:
	return _text_paragraph.get_line_count()


func draw_text(x: float, y: float, draw_alignment: int) -> void:
	match draw_alignment:
		1:
			x -= _text_paragraph.get_size().x
			_text_paragraph.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		2:
			x -= _text_paragraph.get_size().x / 2.0
			_text_paragraph.alignment = HORIZONTAL_ALIGNMENT_CENTER
		_:
			_text_paragraph.alignment = HORIZONTAL_ALIGNMENT_LEFT
	ecGraphics.instance().render_text(_text_paragraph, x, y, color)


func _draw() -> void:
	ecGraphics.instance().render_begin(self)
	draw_text(0.0, 0.0, alignment)
	ecGraphics.instance().render_end()
