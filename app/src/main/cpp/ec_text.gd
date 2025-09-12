@tool
extends Control

const _ecUniFont = preload("res://app/src/main/cpp/ec_uni_font.gd")
const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")

var _text: TextParagraph

@export
var text: String:
	set = set_text

@export
var font: Font:
	set(value):
		if value != font:
			var callable := Callable(self, "_text_changed")
			if font != null:
				font.changed.disconnect(callable)
			font = value
			if font != null:
				font.changed.connect(callable)
			_text_changed()


@export
var font_size: int:
	set(value):
		if value != font_size:
			font_size = value
			_text_changed()


@export
var color := Color.WHITE:
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
			_changed()


func init(value: _ecUniFont) -> void:
	font = value._font
	font_size = value._font_size
	color = Color.WHITE


func set_text(value: String) -> void:
	if value != text:
		text = value
		_text_changed()


func _text_changed() -> void:
	_text.clear()
	if font != null:
		_text.add_string(text, font, font_size if font_size > 0 else 16)
	_changed()


func set_color(value: Color) -> void:
	if value != color:
		color = value
		_changed()


func get_alpha() -> float:
	return color.a


func set_alpha(value: float)-> void:
	if value != color.a:
		color.a = value
		_changed()


func _changed() -> void:
	queue_redraw()


func draw_text(x: float, y: float, override_alignment: HorizontalAlignment) -> void:
	_text.alignment = override_alignment
	var rid := _ecGraphics.instance()._render_target.get_canvas_item()
	_text.draw(rid, Vector2(x, y), color)


## In the original game code, this method can get partial width of a line (i.e.
## the first parameter is char_index instead of line), which is never used and 
## not implemented here.
func get_string_width(line: int, all_lines: bool) -> float:
	if all_lines:
		return _text.get_size().x
	else:
		return _text.get_line_size(line).x


func get_height() -> float:
	return _text.get_size().y


func get_num_lines() -> int:
	return _text.get_line_count()


func _init() -> void:
	_text = TextParagraph.new()
	_text.break_flags = TextServer.BREAK_MANDATORY


func _draw() -> void:
	_text.alignment = alignment
	_text.draw(get_canvas_item(), Vector2.ZERO, color)
