extends Texture2D
 
const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")
const _ecImageAttr = preload("res://app/src/main/cpp/ec_image_attr.gd")

var texture: Texture2D:
	set(value):
		if value != texture:
			texture = value
			changed.emit()


var texture_scale: Vector2:
	set(value):
		if value != texture_scale:
			texture_scale = value
			changed.emit()


var region: Rect2:
	set(value):
		if value != region:
			region = value
			changed.emit()


var ref: Vector2:
	set(value):
		if value != ref:
			ref = value
			changed.emit()


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	var rect := Rect2(pos - ref, region.size)
	var src_rect := region
	src_rect.position *= texture_scale
	src_rect.size *= texture_scale
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	rect.position -= ref
	var src_rect := region
	src_rect.position *= texture_scale
	src_rect.size *= texture_scale
	if tile:
		src_rect.size *= rect.size / region.size
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, not tile)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if texture == null:
		return
	rect.position -= ref
	src_rect.position += region.position
	src_rect.position *= texture_scale
	src_rect.size *= texture_scale
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	if texture == null:
		return 0
	return region.size.x as int


func _get_height() -> int:
	if texture == null:
		return 0
	return region.size.y as int


func _has_alpha() -> bool:
	if texture == null:
		return false
	return texture.has_alpha()


static func from_ec_texture(ec_texture: _ecTexture) -> _ecImageTexture:
	var new_self := _ecImageTexture.new()
	if ec_texture != null:
		new_self.texture = ec_texture.texture
		new_self.texture_scale = ec_texture.texture.get_size() / ec_texture.size_override
		new_self.region = Rect2(Vector2.ZERO, ec_texture.size_override)
		new_self.ref = Vector2.ZERO
	return new_self


static func from_ec_image_attr(attr: _ecImageAttr) -> _ecImageTexture:
	var new_self := _ecImageTexture.new()
	if attr != null:
		new_self.texture = attr.texture.texture
		new_self.texture_scale = attr.texture.texture.get_size() / attr.texture.size_override
		new_self.region = attr.region
		new_self.ref = attr.ref
	return new_self
