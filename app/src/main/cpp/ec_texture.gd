@tool
class_name ecTexture
extends Texture2D

## In the original game code, ecTexture is a simple struct that is managed by
## ecGraphics to store texture handle and size. The size is half of the actual
## size if the texture is the "@2x" varient. Since the uv coordinates, used to
## specify a region of the source texture, is ranged between 0.0 and 1.0, this
## shrinked size effectively shrinks the texture when rendering. The size is set
## by ecTextureLoad and its variants.
## 
## In this Godot port, this class can be used independently as a Texture2D, and
## a ResourceFormatLoader is implemented so that its usage is not limited to
## ecGraphics. It can also be used to represent an atlas from an ecTextureRes.

const _ecTextureResFile = preload("res://app/src/main/cpp/ec_texture_res_file.gd")
const _ecTextureRect = preload("res://app/src/main/cpp/ec_texture_rect.gd")

@export
var texture_res: _ecTextureResFile:
	set(value):
		if value != texture_res:
			texture_res = value
			_set_from_res()


@export
var texture_scale_override: float:
	set(value):
		if value != texture_scale_override:
			texture_scale_override = value
			_set_from_res()


@export
var name: StringName:
	set(value):
		if value != name:
			name = value
			_set_from_res()


@export
var texture: Texture2D:
	set(value):
		if value != texture:
			texture = value
			_set_from_attr()


@export
var texture_scale: float:
	set(value):
		if value != texture_scale:
			texture_scale = value
			_set_from_attr()


@export
var region: Rect2:
	set(value):
		if value != region:
			region = value
			_set_from_attr()


@export
var ref: Vector2:
	set(value):
		if value != ref:
			ref = value
			_set_from_attr()


var _texture: Texture2D
var _texture_scale := 1.0
var _region: Rect2
var _origin: Vector2

func _set_from_res() -> void:
	if texture_res == null:
		return
	texture = null
	if name.is_empty():
		return
	var attr: _ecTextureRect = texture_res.images.get(name)
	if attr == null:
		return
	var res_path := texture_res.resource_path
	var texture_path = res_path.substr(0, res_path.rfind('/') + 1) + texture_res.texture_name
	_texture = load(texture_path) as Texture2D
	_texture_scale = texture_res.texture_scale if texture_scale_override == 0.0 else texture_scale_override
	_region = Rect2(attr.x, attr.y, attr.w, attr.h)
	_origin = Vector2(attr.refx, attr.refy)
	changed.emit()


func _set_from_attr() -> void:
	if texture == null:
		return
	texture_res = null
	_texture = texture
	_texture_scale = texture_scale if texture_scale != 0.0 else 1.0
	_region = region if region else Rect2(Vector2.ZERO, texture.get_size())
	_origin = ref
	changed.emit()


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if _texture == null:
		return
	var size := _region.size / _texture_scale
	pos -= _origin / _texture_scale
	_texture.draw_rect_region(to_canvas_item, Rect2(pos, size), _region, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, _tile: bool, modulate: Color, transpose: bool) -> void:
	if _texture == null:
		return
	rect.position -= _origin / _texture_scale
	texture.draw_rect_region(to_canvas_item, rect, _region, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if _texture == null:
		return
	rect.position -= _origin / _texture_scale
	src_rect.position = _region.position + src_rect.position * _texture_scale
	src_rect.size *= _texture_scale
	_texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	return (_region.size.x / _texture_scale) as int


func _get_height() -> int:
	return (_region.size.y / _texture_scale) as int


func _has_alpha() -> bool:
	if _texture == null:
		return false
	return _texture.has_alpha()


func _validate_property(property: Dictionary) -> void:
	if property["name"] == "texture_res":
		if texture != null:
			property["usage"] |= PROPERTY_USAGE_NO_EDITOR
			property["usage"] &= ~PROPERTY_USAGE_EDITOR
	elif property["name"] == "texture_scale_override":
		if texture_res == null:
			property["usage"] |= PROPERTY_USAGE_NO_EDITOR
			property["usage"] &= ~PROPERTY_USAGE_EDITOR
	elif property["name"] == "name":
		if texture_res == null:
			property["usage"] |= PROPERTY_USAGE_NO_EDITOR
			property["usage"] &= ~PROPERTY_USAGE_EDITOR
	elif property["name"] == "texture":
		if texture_res != null:
			property["usage"] |= PROPERTY_USAGE_NO_EDITOR
			property["usage"] &= ~PROPERTY_USAGE_EDITOR
	elif property["name"] == "texture_scale":
		if texture == null:
			property["usage"] |= PROPERTY_USAGE_NO_EDITOR
			property["usage"] &= ~PROPERTY_USAGE_EDITOR
	elif property["name"] == "region":
		if texture == null:
			property["usage"] |= PROPERTY_USAGE_NO_EDITOR
			property["usage"] &= ~PROPERTY_USAGE_EDITOR
	elif property["name"] == "ref":
		if texture == null:
			property["usage"] |= PROPERTY_USAGE_NO_EDITOR
			property["usage"] &= ~PROPERTY_USAGE_EDITOR
