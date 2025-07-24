@tool
extends EditorImportPlugin

## Note: The image for the font is not loaded with ecGraphics::LoadTexture,
## which means the @2x variant is not considered.

# Reference: Godot source code of Image Font importer (https://github.com/godotengine/godot/blob/master/editor/import/resource_importer_imagefont.cpp)

func _get_importer_name() -> String:
	return "wc2.assets.fnt"


func _get_visible_name() -> String:
	return "Font Data (ecUniFont)"


func _get_format_version() -> int:
	return 1


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["fnt"])


func _get_priority() -> float:
	return 2.0 # Take priority over the default .fnt importer.


func _get_import_order() -> int:
	return 1


func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	return []


func _get_option_visibility(_path: String, _option_name: StringName, _options: Dictionary) -> bool:
	return true


func _get_preset_count() -> int:
	return 0


func _get_preset_name(preset_index: int) -> String:
	return ""


func _get_resource_type() -> String:
	return "FontFile"


func _get_save_extension() -> String:
	return "res"


func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var file := FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		var err := FileAccess.get_open_error()
		push_error("{0}: Failed to open {1}".format([error_string(err), source_file]))
		return err
	if file.get_length() < 8:
		push_error("Failed to import {0}: File too small".format([source_file]))
		return ERR_PARSE_ERROR
	var glyph_count = file.get_32()
	if file.get_length() != 8 + 12 * glyph_count:
		push_error("Failed to import {0}: Unexpected file length: expected {1}, got {2}".format([source_file, 8 + 12 * glyph_count, file.get_length()]))
		return ERR_PARSE_ERROR
	var img_path := source_file.left(-3) + "png"
	var err := append_import_external_resource(img_path, {}, "image")
	if err != OK:
		push_error("{0}: Failed to import font image {1}".format([error_string(err), img_path]))
		return err
	var img:Image = load(img_path)
	var chr_height := file.get_32()
	var font := FontFile.new()
	font.set_antialiasing(TextServer.FONT_ANTIALIASING_NONE)
	font.set_generate_mipmaps(false)
	font.set_multichannel_signed_distance_field(false)
	font.set_fixed_size(chr_height)
	font.set_subpixel_positioning(TextServer.SUBPIXEL_POSITIONING_DISABLED)
	font.set_keep_rounding_remainders(true)
	font.set_force_autohinter(false)
	#font.set_modulate_color_glyphs(false)
	font.set_allow_system_fallback(true)
	font.set_hinting(TextServer.HINTING_NONE)
	font.set_fallbacks([])
	font.set_texture_image(0, Vector2i(chr_height, 0), 0, img)
	font.set_fixed_size_scale_mode(TextServer.FIXED_SIZE_SCALE_ENABLED)
	for i in glyph_count:
		var idx := file.get_16()
		var uv_x := file.get_16()
		var uv_y := file.get_16()
		var chr_width := file.get_8()
		chr_height = file.get_8()
		var chr_off_x := -file.get_buffer(1).decode_s8(0)
		var chr_off_y := -file.get_buffer(1).decode_s8(0)
		var chr_adv := file.get_16()
		font.set_glyph_advance(0, chr_height, idx, Vector2(chr_adv, 0));
		font.set_glyph_offset(0, Vector2i(chr_height, 0), idx, Vector2i(chr_off_x, -0.5 * chr_height + chr_off_y));
		font.set_glyph_size(0, Vector2i(chr_height, 0), idx, Vector2(chr_width, chr_height));
		font.set_glyph_uv_rect(0, Vector2i(chr_height, 0), idx, Rect2(uv_x, uv_y, chr_width, chr_height));
		font.set_glyph_texture_idx(0, Vector2i(chr_height, 0), idx, 0);
	font.set_cache_ascent(0, chr_height, 0.5 * chr_height)
	font.set_cache_descent(0, chr_height, 0.5 * chr_height)
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(font, filename)
