@tool
class_name ecImageAttr
extends Texture2D

@export
var texture_res: ecTextureRes:
	set(value):
		if value != texture_res:
			if texture_res != null:
				texture_res.changed.disconnect(_on_asset_changed)
			texture_res = value
			_on_asset_changed()
			if value != null:
				value.changed.connect(_on_asset_changed)


@export
var image: AssetRegistry:
	set(value):
		if value != image:
			if image != null:
				image.changed.disconnect(_on_asset_changed)
			image = value
			_on_asset_changed()
			if value != null:
				value.changed.connect(_on_asset_changed)


var texture: ecTexture:
	set(value):
		if value != texture:
			if texture != null:
				texture.changed.disconnect(emit_changed)
			texture = value
			if value != null:
				value.changed.connect(emit_changed)
			emit_changed()


@export
var region: Rect2:
	set(value):
		if value != region:
			region = value
			emit_changed()


@export
var origin: Vector2:
	set(value):
		if value != origin:
			origin = value
			emit_changed()


func _on_asset_changed() -> void:
	if image != null:
		if texture_res != null:
			var attr: ecImageAttr
			if Engine.is_editor_hint():
				attr = texture_res.get_image(image.name)
				if attr == null:
					attr = texture_res.get_image(image.name_hd)
			else:
				var image_name := image.get_resolved_name()
				if not image_name.is_empty():
					attr = texture_res.get_image(image_name)
			if attr != null:
				texture = attr.texture
				region = attr.region
				origin = attr.origin
			else:
				texture = null
				region = Rect2()
				origin = Vector2.ZERO
		else:
			if Engine.is_editor_hint():
				texture = EC2dAppDelegate.ec_texture_load(image.name)
				if texture == null:
					texture = EC2dAppDelegate.ec_texture_load(image.name_hd)
			else:
				var image_name := image.get_resolved_name()
				if not image_name.is_empty():
					texture = ecGraphics.instance().load_texture(image_name)
	notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if image != null and (property.name == "texture"):
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if texture_res != null and (property.name == "texture" or property.name == "region" or property.name == "origin"):
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	if not Engine.is_editor_hint():
		texture.complete_loading()
	if texture.texture == null:
		return
	var texture_scale := texture.texture.get_size() / texture.size_override
	var rect := Rect2(pos - origin, region.size)
	var src_rect := region
	src_rect.position *= texture_scale
	src_rect.size *= texture_scale
	texture.texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, true)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	if not Engine.is_editor_hint():
		texture.complete_loading()
	if texture.texture == null:
		return
	var texture_scale := texture.texture.get_size() / texture.size_override
	rect.position -= origin
	var src_rect := region
	src_rect.position *= texture_scale
	src_rect.size *= texture_scale
	if tile:
		src_rect.size *= rect.size / src_rect.size
		texture.texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, false)
	else:
		texture.texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, true)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if texture == null:
		return
	if not Engine.is_editor_hint():
		texture.complete_loading()
	if texture.texture == null:
		return
	var texture_scale := texture.texture.get_size() / texture.size_override
	rect.position -= origin
	src_rect.position += region.position
	src_rect.position *= texture_scale
	src_rect.size *= texture_scale
	texture.texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	return region.size.x as int


func _get_height() -> int:
	return region.size.y as int


func _has_alpha() -> bool:
	if texture == null or texture.texture == null:
		return false
	return texture.texture.has_alpha()


func _get_rid() -> RID:
	if texture == null or texture.texture == null:
		return RID()
	return texture.texture.get_rid()
