@tool
class_name ecImage
extends Texture2D

## In the original game code, ecImage represent a rectanglar region of a texture
## with an translated origin for rendering. It can be rendered in various ways.
## 
## In this Godot port, this class can be used independently as a Texture2D. The
## texture, region and origin can be set directly, or by an entry in an
## ecTextureRes.

const _ecTextureRes = preload("res://app/src/main/cpp/imported/ec_texture_res.gd")
const _ecImageAttr = preload("res://app/src/main/cpp/imported/ec_image_attr.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")

@export_group("ecTextureRes")
@export
var texture_res: _ecTextureRes:
	set(value):
		texture_res = value
		_set_from_res()


@export
var name: StringName:
	set(value):
		name = value
		_set_from_res()


@export_group("ecImageAttr")
@export
var texture: Texture2D:
	get(): return _texture
	set(value):
		_texture = value
		_validate_res()


@export
var region: Rect2:
	get(): return _region
	set(value):
		_region = value
		_validate_res()


@export
var origin: Vector2:
	get(): return _origin
	set(value):
		_origin = value
		_validate_res()


var _texture: Texture2D
var _region: Rect2
var _origin: Vector2


func _set_from_res() -> void:
	if texture_res == null or name.is_empty():
		return
	var attr: _ecImageAttr = texture_res.images.get(name)
	if attr == null:
		return
	_texture = load(attr.texture_path) as Texture2D
	if attr.scale != 1.0:
		var ec_texture := _ecTexture.new()
		ec_texture.size_override = _texture.get_size() / attr.scale
		ec_texture.texture = _texture
		_texture = ec_texture
		var pos := Vector2(attr.x, attr.y) / attr.scale
		var size := Vector2(attr.w, attr.h) / attr.scale
		_region = Rect2(pos, size)
		_origin = Vector2(attr.refx, attr.refy) / attr.scale
	else:
		_region = Rect2(attr.x, attr.y, attr.w, attr.h)
		_origin = Vector2(attr.refx, attr.refy)


func _validate_res() -> void:
	if texture_res == null or name.is_empty():
		name = &""
		return
	var attr: _ecImageAttr = texture_res.images.get(name)
	if attr == null:
		name = &""
		return
	var expected_texture = load(attr.texture_path) as Texture2D
	if attr.scale != 1.0:
		var pos := Vector2(attr.x, attr.y) / attr.scale
		var size := Vector2(attr.w, attr.h) / attr.scale
		if _texture == null or _texture.texture != expected_texture\
				or _region != Rect2(pos, size)\
				or _origin != Vector2(attr.refx, attr.refy) / attr.scale:
			name = &""
	elif _texture != expected_texture\
			or _region != Rect2(attr.x, attr.y, attr.w, attr.h)\
			or _origin != Vector2(attr.refx, attr.refy):
		name = &""


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	var size := region.size
	texture.draw_rect_region(to_canvas_item, Rect2(pos - origin, size), region, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, _tile: bool, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	rect.position -= origin
	texture.draw_rect_region(to_canvas_item, rect, region, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if texture == null:
		return
	rect.position -= origin
	src_rect.position += region.position
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	return region.size.x as int


func _get_height() -> int:
	return region.size.y as int


func _has_alpha() -> bool:
	if texture == null:
		return false
	return texture.has_alpha()
