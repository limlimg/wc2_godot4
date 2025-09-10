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
var ignore_texture_scale: bool:
	set(value):
		ignore_texture_scale = value
		_set_from_res()


@export
var name: StringName:
	set(value):
		name = value
		_set_from_res()


@export_group("ecImageAttr")
@export
var texture: Texture2D:
	set(value):
		texture = value
		_set_from_attr()


@export
var region: Rect2:
	set(value):
		region = value
		_set_from_attr()


@export
var origin: Vector2:
	set(value):
		origin = value
		_set_from_attr()


var _texture: Texture2D
var _region: Rect2
var _origin: Vector2


func _set_from_res() -> void:
	if texture_res == null or name.is_empty():
		return
	texture = null
	var attr: _ecImageAttr = texture_res.images.get(name)
	if attr == null:
		return
	_texture = load(attr.texture_path) as Texture2D
	if attr.texture_scale != 1.0 and not ignore_texture_scale:
		var ec_texture := _ecTexture.new()
		ec_texture.size_override = _texture.get_size() / attr.texture_scale
		ec_texture.texture = _texture
		_texture = ec_texture
		var pos := Vector2(attr.x, attr.y) / attr.texture_scale
		var size := Vector2(attr.w, attr.h) / attr.texture_scale
		_region = Rect2(pos, size)
		_origin = Vector2(attr.refx, attr.refy) / attr.texture_scale
	else:
		_region = Rect2(attr.x, attr.y, attr.w, attr.h)
		_origin = Vector2(attr.refx, attr.refy)


func _set_from_attr() -> void:
	if texture == null or not region.has_area():
		return
	texture_res = null
	_texture = texture
	_region = region
	_origin = origin


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if _texture == null:
		return
	var size := _region.size
	_texture.draw_rect_region(to_canvas_item, Rect2(pos - _origin, size), _region, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, _tile: bool, modulate: Color, transpose: bool) -> void:
	if _texture == null:
		return
	rect.position -= _origin
	texture.draw_rect_region(to_canvas_item, rect, _region, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if _texture == null:
		return
	rect.position -= _origin
	src_rect.position += _region.position
	_texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	return _region.size.x as int


func _get_height() -> int:
	return _region.size.y as int


func _has_alpha() -> bool:
	if _texture == null:
		return false
	return _texture.has_alpha()
