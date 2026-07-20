extends Label

@export
var font: NodePath:
	set(value):
		if value != font:
			if not is_inside_tree():
				await tree_entered
			var node := get_node_or_null(font)
			if node != null:
				node.theme_changed.disconnect(init)
			font = value
			init()
			node = get_node_or_null(value)
			if node != null:
				node.theme_changed.connect(init)


@export
var color: Color = Color.WHITE:
	set = set_color

@export
var alpha := 1.0:
	get = get_alpha,
	set = set_alpha

@export
var spacing := Vector2i.ZERO:
	set = set_spacing

func init():
	if not Engine.get_main_loop().root.is_node_ready():
		await Engine.get_main_loop().root.ready
	var old_spacing := spacing
	set_spacing(Vector2i.ZERO)
	remove_theme_font_override(&"font")
	var node := get_node_or_null(font) as Control
	if node != null:
		theme = node.theme
	else:
		theme = null
	set_spacing(old_spacing)


func set_color(value: Color) -> void:
	if value != color:
		color = value
		add_theme_color_override(&"font_color", value)


func get_alpha() -> float:
	return color.a


func set_alpha(value: float) -> void:
	set_color(Color(color, value))


func set_spacing(value: Vector2i) -> void:
	if value != spacing:
		spacing = value
		var theme_font := get_theme_font(&"font")
		var new_font: Font
		if value != Vector2i.ZERO:
			if theme_font is FontVariation:
				new_font = theme_font.duplicate()
				new_font.base_font = theme_font.base_font
			else:
				new_font = FontVariation.new()
				new_font.base_font = theme_font
		else:
			if theme_font is FontVariation:
				new_font = theme_font.duplicate()
			else:
				new_font = theme_font
		if new_font is FontVariation:
			new_font.spacing_glyph = value.x
			new_font.spacing_bottom = value.y
		add_theme_font_override(&"font", new_font)


func get_height() -> float:
	return size.y


func get_string_width(from_pos: int, to_string_end: bool) -> float:
	var width := 0.0
	var line_width := 0.0
	var length := text.length()
	while from_pos < length:
		if text[from_pos] == '\n':
			if not to_string_end:
				return line_width
			if line_width > width:
				width = line_width
			line_width = 0.0
		else:
			line_width += get_character_bounds(from_pos).size.x
		from_pos += 1
	return width


func get_num_lines() -> int:
	return get_line_count()


func draw_text(x: float, y: float, draw_alignment: int) -> void:
	match draw_alignment:
		1:
			x -= get_string_width(0, true)
		2:
			x -= get_string_width(0, true) / 2.0
	ecGraphics.instance().render_text(get_theme_font(&"font"), x, y, text, draw_alignment\
		, get_theme_font_size(&"font_size"), get_theme_color(&"font_color"))
