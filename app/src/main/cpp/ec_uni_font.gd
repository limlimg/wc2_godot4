extends Theme

## This class extends Theme because it hold both a font and a font size. The
## .fnt files are imported as FontFile. @2x variant is not supported for the
## associated images.

const _Profile = preload("res://app/src/main/cpp/runtime_resource/ec_uni_font_profile.gd")
const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")

@export
var profile: _Profile:
	set=set_profile

var _last_selected_name: String

func set_profile(value: _Profile):
		if value != profile:
			if profile != null:
				profile.changed.disconnect(_profile_changed)
			profile = value
			if profile != null:
				_profile_changed()
				profile.changed.connect(_profile_changed)
			else:
				default_font = null
				_last_selected_name = ""


func _profile_changed() -> void:
	var selected_name: String
	var is_hd := false
	if not Engine.is_editor_hint():
		if not profile.name_ipad.is_empty() and _ecGraphics.instance().content_scale_size_mode == 3:
			selected_name = profile.name_ipad
		elif not profile.name_hd.is_empty() and _native.g_content_scale_factor == 2.0:
			selected_name = profile.name_hd
			is_hd = true
		else:
			selected_name = profile.name
	else:
		selected_name = profile.name
	if selected_name.is_empty():
		default_font = null
		return
	selected_name = selected_name.format([_native.g_localizable_strings.get_string("language")])
	if _last_selected_name == selected_name:
		return
	_last_selected_name = selected_name
	var selected_path := _native.get_path_alias(selected_name, "")
	var font: FontFile
	if not selected_path.is_empty():
		font = load(selected_path) as FontFile
	if font == null and Engine.is_editor_hint(): # in the editor, the situation is considered where only _hd variant exists
		selected_path = _native.get_path_alias(profile.name_hd, "")
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
	var new_profile := _Profile.new()
	if hd:
		new_profile.name_hd = file_name
	else:
		new_profile.name = file_name
	set_profile(new_profile)
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
