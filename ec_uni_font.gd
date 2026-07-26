@tool
class_name ecUniFont
extends Control

## .fnt files are imported as FontFile. @2x variant is not supported for the
## associated images.

@export
var asset: AssetRegistry:
	set(value):
		if value != asset:
			if asset != null:
				asset.changed.disconnect(_on_asset_changed)
			asset = value
			_on_asset_changed()
			if value != null:
				value.changed.connect(_on_asset_changed)


@export
var spacing := Vector2i.ZERO:
	get = get_spacing,
	set = set_spacing


func _on_asset_changed() -> void:
	if asset != null:
		if Engine.is_editor_hint():
			if not init(asset.name, false):
				init(asset.name_hd, true)
		else:
			var font_name := await asset.get_resolved_name()
			if not font_name.is_empty():
				init(font_name, await asset.is_hd())
	notify_property_list_changed()


func init(font_name: String, hd: bool) -> bool:
	var cache_old_theme := theme
	theme = null
	var path := EC2dAppDelegate.get_asset_path(font_name, "")
	if path.is_empty():
		return false
	var old_spacing := spacing
	spacing = Vector2i.ZERO # change back after theme loaded to trigger setter
	if cache_old_theme == null:
		cache_old_theme = Theme.new()
	cache_old_theme.default_font = load(path) as FontFile
	if cache_old_theme.default_font == null:
		push_error("Failed to load {0}".format([font_name]))
		return false
	if hd:
		cache_old_theme.default_font_size = cache_old_theme.default_font.fixed_size / 2
	else:
		cache_old_theme.default_font_size = cache_old_theme.default_font.fixed_size
	theme = cache_old_theme
	set_spacing(old_spacing)
	return true


func get_spacing() -> Vector2i:
	if theme == null or theme.default_font == null or theme.default_font is not FontVariation:
		return Vector2i.ZERO
	else:
		return Vector2i(theme.default_font.spacing_glyph, theme.default_font.spacing_bottom)


func set_spacing(value: Vector2i) -> void:
	if theme == null:
		return
	if value != spacing:
		if value != Vector2i.ZERO:
			if theme.default_font != null:
				if theme.default_font is not FontVariation:
					var font_var := FontVariation.new()
					font_var.base_font = theme.default_font
					theme.default_font = font_var
				theme.default_font.spacing_glyph = value.x
				theme.default_font.spacing_bottom = value.y
		else:
			if theme.default_font is FontVariation:
				theme.default_font = theme.default_font.base_font


func _validate_property(property: Dictionary) -> void:
	if asset != null and property.name == "theme":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY


func release() -> void:
	asset = null
	theme = null


func get_char_image(glyph: int) -> Image:
	var font := theme.default_font as FontFile
	if font == null or not font.has_char(glyph):
		return null
	var font_size := Vector2i(theme.default_font_size, 0)
	var idx := font.get_glyph_texture_idx(0, font_size, glyph)
	var image := font.get_texture_image(0, font_size, idx)
	if image == null:
		return null
	var region := font.get_glyph_uv_rect(0, font_size, glyph)
	return image.get_region(region)
