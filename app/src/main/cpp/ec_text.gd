
const _ecUniFont = preload("res://app/src/main/cpp/ec_uni_font.gd")
const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")

var _text: TextParagraph 
var _text_string: String
var _font: _ecUniFont
var _color := Color.WHITE

func init(font: _ecUniFont) -> void:
	_font = font
	_color = Color.WHITE


func set_text(text: String) -> void:
	_text.clear()
	_text.add_string(text, _font._font, _font._font_size)
	_text_string = text


func set_color(color: Color) -> void:
	_color = color


func set_alpha(alpha: float)-> void:
	_color.a = alpha


func draw_text(x: float, y: float, alignment: HorizontalAlignment) -> void:
	_text.alignment = alignment
	var rid := _ecGraphics.instance()._render_target.get_canvas_item()
	_text.draw(rid, Vector2(x, y), _color)


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
