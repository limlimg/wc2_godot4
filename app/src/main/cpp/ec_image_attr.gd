@tool
class_name ecImageAttr
extends Texture2D

## In original game code, this struct is created by ecTextureRes for
## initializing ecImage according to a region and ref from an .xml file.
## 
## In this Godot port, this class can also be used as a Texture2D for unsing in
## the scene system.

const _ecTextureRes = preload("res://app/src/main/cpp/imported_containers/ec_texture_res.gd")
const _ecTextureRect = preload("res://app/src/main/cpp/ec_texture_rect.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")

@export
var texture_res: _ecTextureRes:
	set(value):
		if value != texture_res:
			texture_res = value
			_set_from_res()


@export
var hd: bool:
	set(value):
		if value != hd:
			hd = value
			_set_from_res()


@export
var name: StringName:
	set(value):
		if value != name:
			name = value
			_set_from_res()


var texture: Texture2D:
	set(value):
		if value != texture:
			texture = value
			changed.emit()


var x: float:
	set(value):
		if value != x:
			x = value
			changed.emit()


var y: float:
	set(value):
		if value != y:
			y = value
			changed.emit()


var w: float:
	set(value):
		if value != w:
			w = value
			changed.emit()


var h: float:
	set(value):
		if value != h:
			h = value
			changed.emit()


var refx: float:
	set(value):
		if value != refx:
			refx = value
			changed.emit()


var refy: float:
	set(value):
		if value != refy:
			refy = value
			changed.emit()


func _set_from_res() -> void:
	if texture_res == null or name.is_empty():
		return
	var attr: _ecTextureRect = texture_res.images.get(name)
	if attr == null:
		return
	var texture_res_path := texture_res.resource_path
	var texture_path := texture_res_path.substr(0, texture_res_path.rfind('/') + 1) + texture_res.texture_name
	var loaded_texture := load(texture_path) as Texture2D
	if loaded_texture == null:
		return
	texture = loaded_texture
	var res_hd = texture_res_path.substr(texture_res_path.rfind('.') - 3, 3) == "_hd"
	if hd or (not res_hd and texture_res.hd):
		if texture is _ecTexture and texture.res_scale == 1.0:
			texture.size_override /= 2.0
			texture.res_scale = 2.0
		else:
			var ec_texture := _ecTexture.new()
			ec_texture.texture = texture
			ec_texture.size_override = texture.get_size() / 2.0
			ec_texture.res_scale = 2.0
			texture = ec_texture
		x = attr.x / 2.0
		y = attr.y / 2.0
		w = attr.w / 2.0
		h = attr.h / 2.0
		refx = attr.refx / 2.0
		refy = attr.refy / 2.0
	else:
		x = attr.x
		y = attr.y
		w = attr.w
		h = attr.h
		refx = attr.refx
		refy = attr.refy


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	pos -= Vector2(refx, refy)
	var size := Vector2(w, h)
	var region = Rect2(x, y, w, h)
	texture.draw_rect_region(to_canvas_item, Rect2(pos, size), region, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	rect.position -= Vector2(refx, refy)
	var region = Rect2(x, y, w, h)
	texture.draw_rect_region(to_canvas_item, rect, region, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if texture == null:
		return
	rect.position -= Vector2(refx, refy)
	src_rect.position += Vector2(x, y)
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	return w


func _get_height() -> int:
	return h


func _has_alpha() -> bool:
	if texture == null:
		return false
	return texture.has_alpha()
