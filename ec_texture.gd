@tool
class_name ecTexture
extends Texture2D

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
var texture: Texture2D:
	set(value):
		if value != texture:
			if texture != null:
				texture.changed.disconnect(_on_texture_changed)
			texture = value
			_on_texture_changed()
			if value != null:
				value.changed.connect(_on_texture_changed)


@export
var size_override: Vector2:
	set(value):
		if value != size_override:
			size_override = value
			emit_changed()

@export
var res_scale := 1.0

func _on_asset_changed() -> void:
	if asset != null:
		if Engine.is_editor_hint():
			texture = ecGraphics.instance().load_texture(asset.name)
			if texture == null:
				texture = ecGraphics.instance().load_texture(asset.name_hd)
		else:
			var name := asset.get_resolved_name()
			if not name.is_empty():
				texture = ecGraphics.instance().load_texture(name)
	notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if asset != null and (property.name == "texture" or property.name == "size_override"):
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY


func _on_texture_changed() -> void:
	if texture is ecTexture:
		size_override = texture.size_override / res_scale


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	var rect := Rect2(pos, size_override)
	texture.draw_rect(to_canvas_item, rect, false, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	if tile:
		var src_rect := Rect2(Vector2.ZERO, texture.get_size())
		src_rect.size *= rect.size / size_override
		texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, false)
	else:
		texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if texture == null:
		return
	var texture_size := texture.get_size()
	src_rect.position *= texture_size / size_override
	src_rect.size *= texture_size / size_override
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	return size_override.x as int


func _get_height() -> int:
	return size_override.y as int


func _has_alpha() -> bool:
	if texture == null:
		return false
	return texture.has_alpha()


func _get_rid() -> RID:
	if texture == null:
		return RID()
	return texture.get_rid()
