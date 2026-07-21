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
			texture = value
			emit_changed()


@export
var size_override: Vector2:
	set(value):
		if value != size_override:
			size_override = value
			emit_changed()

@export
var res_scale := 1.0

var _clone_from: ecTexture:
	set(value):
		if value != _clone_from:
			if _clone_from != null:
				_clone_from.changed.disconnect(_on_clone_changed)
			_clone_from = value
			_on_clone_changed()
			if value != null:
				value.changed.connect(_on_clone_changed)


func _on_asset_changed() -> void:
	if asset != null:
		var clone_texture: ecTexture
		if Engine.is_editor_hint():
			clone_texture = ecGraphics.instance().load_texture(asset.name)
			if clone_texture == null:
				clone_texture = ecGraphics.instance().load_texture(asset.name_hd)
			if clone_texture != null:
				texture = clone_texture.texture
				size_override = clone_texture.size_override / res_scale
			else:
				texture = null
				size_override = Vector2.ZERO
		else:
			var name := await asset.get_resolved_name()
			if not name.is_empty():
				_clone_from = ecGraphics.instance().load_texture(name)
	notify_property_list_changed()


func _on_clone_changed() -> void:
	texture = _clone_from.texture
	size_override = _clone_from.size_override / res_scale


func _validate_property(property: Dictionary) -> void:
	if asset != null and (property.name == "texture" or property.name == "size_override"):
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY


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
