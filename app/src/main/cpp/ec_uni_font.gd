extends Theme

## THis class extends Theme because it hold both a font and a font size. The
## .fnt files are imported as FontFile. @2x variant is not supported for the
## associated images.

const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")

@export
var font_name: String:
	set=set_font_name

@export
var font_name_hd: String:
	set=set_font_name_hd

@export
var font_name_ipad: String:
	set=set_font_name_ipad

func set_font_name(value: String) -> void:
		if value != font_name:
			font_name = value
			_changed()


func set_font_name_hd(value: String) -> void:
		if value != font_name_hd:
			font_name_hd = value
			_changed()


func set_font_name_ipad(value: String) -> void:
		if value != font_name:
			font_name = value
			_changed()


func _changed() -> void:
	var selected_name: String
	var is_hd := false
	if not Engine.is_editor_hint():
		if not font_name_ipad.is_empty() and _ecGraphics.instance().content_scale_size_mode == 3:
			selected_name = font_name_ipad
		elif not font_name_hd.is_empty() and _native.g_content_scale_factor == 2.0:
			selected_name = font_name_hd
			is_hd = true
		else:
			selected_name = font_name
	else:
		selected_name = font_name
	if selected_name.is_empty():
		default_font = null
		return
	var selected_path := _native.get_path_alias(selected_name, "")
	var font: FontFile
	if not selected_path.is_empty():
		font = load(selected_path) as FontFile
	if font == null and Engine.is_editor_hint(): # in the editor, the situation is considered where only _hd variant exists
		selected_path = _native.get_path_alias(font_name_hd, "")
		if not selected_path.is_empty():
			font = load(selected_path) as FontFile
	if font == null:
		default_font = null
		return
	default_font = font
	if is_hd:
		default_font_size = default_font.fixed_size / 2
	else:
		default_font_size = default_font.fixed_size


func init(file_name: String, hd: bool) -> void:
	var old_font = default_font
	if hd:
		set_font_name_hd(file_name)
	else:
		set_font_name(file_name)
	default_font.fallbacks.append(old_font)


func release() -> void:
	default_font = null


func get_char_image(glyph: int) -> Image:
	if not default_font.has_char(glyph):
		return null
	var font := default_font as FontFile
	if font == null:
		return null
	var size := Vector2(default_font_size, 0)
	var idx := font.get_glyph_texture_idx(0, size, glyph)
	var image := font.get_texture_image(0, size, idx)
	if image == null:
		return null
	var region := font.get_glyph_uv_rect(0, size, glyph)
	return image.get_region(region)
