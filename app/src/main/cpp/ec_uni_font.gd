@tool
class_name ecUniFont
extends Theme

const _AssetRegistry = preload("res://app/src/main/cpp/resources/assets/asset_registry.gd")
const _lib = preload("res://app/src/main/cpp/native-lib.gd")

## .fnt files are imported as FontFile. @2x variant is not supported for the
## associated images.

@export
var asset: _AssetRegistry:
	set(value):
		if value != asset:
			if asset != null:
				asset.changed.disconnect(init)
			asset = value
			init()
			if value != null:
				value.changed.connect(init)


@export
var spacing := Vector2i.ZERO:
	get = get_spacing,
	set = set_spacing


func init() -> void:
	var value := spacing
	if asset != null:
		default_font = null
		default_font_size = -1
		if Engine.is_editor_hint():
			default_font = load(_lib.get_asset_path(asset.name, "")) as FontFile
			if default_font == null:
				return
			default_font_size = default_font.fixed_size
			if default_font:
				default_font = load(_lib.get_asset_path(asset.name_hd, "")) as FontFile
				default_font_size = default_font.fixed_size / 2
		else:
			var name := asset.get_resolved_name()
			if name != null:
				var path := _lib.get_asset_path(name, "")
				if path != null:
					default_font = load(path) as FontFile
				if asset.is_hd():
					default_font_size = default_font.fixed_size / 2
				else:
					default_font_size = default_font.fixed_size
	set_spacing(value)
	notify_property_list_changed()


func get_spacing() -> Vector2i:
	if default_font is not FontVariation:
		return Vector2i.ZERO
	else:
		return Vector2i(default_font.spacing_glyph, default_font.spacing_bottom)


func set_spacing(value: Vector2i) -> void:
	if value != spacing:
		if value != Vector2i.ZERO:
			if default_font != null:
				if default_font is not FontVariation:
					var font_var := FontVariation.new()
					font_var.base_font = default_font
					default_font = font_var
				default_font.spacing_glyph = value.x
				default_font.spacing_bottom = value.y
		else:
			if default_font is FontVariation:
				default_font = default_font.base_font


func _validate_property(property: Dictionary) -> void:
	if asset != null and (property.name == "default_font" or property.name == "default_font_size"):
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY


func release() -> void:
	asset = null


func get_char_image(glyph: int) -> Image:
	var font := default_font as FontFile
	if font == null or not font.has_char(glyph):
		return null
	var size := Vector2i(default_font_size, 0)
	var idx := font.get_glyph_texture_idx(0, size, glyph)
	var image := font.get_texture_image(0, size, idx)
	if image == null:
		return null
	var region := font.get_glyph_uv_rect(0, size, glyph)
	return image.get_region(region)
