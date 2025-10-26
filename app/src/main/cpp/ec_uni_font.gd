extends Theme

## This class extends Theme because it hold both a font and a font size. The
## .fnt files are imported as FontFile. @2x variant is not supported for the
## associated images.

func init(file_name: String, hd: bool) -> void:
	default_font = load(file_name) as FontFile
	if hd:
		default_font_size = default_font.fixed_size / 2
	else:
		default_font_size = default_font.fixed_size


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
