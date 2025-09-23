@tool
class_name ecImageAttr
extends Texture2D

## In original game code, this struct is created by ecTextureRes for
## initializing ecImage according to a region and ref from an .xml file.
## 
## In this Godot port, this class can also be used as a Texture2D for unsing in
## the scene system.

const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _ecTextureRes = preload("res://app/src/main/cpp/imported_containers/ec_texture_res.gd")
const _ecTextureRect = preload("res://app/src/main/cpp/ec_texture_rect.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")
const _AssetManager = preload("res://core/java/android/content/res/asset_manager.gd")

@export
var texture_res_name: String:
	set=set_texture_res_name

@export
var texture_res_name_hd: String:
	set=set_texture_res_name_hd

@export
var texture_res_name_ipad: String:
	set=set_texture_res_name_ipad

@export
var name: StringName:
	set=set_image_name

var texture: Texture2D:
	set(value):
		if value != texture:
			texture = value
			changed.emit()


var texture_scale: float:
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


func set_texture_res_name(value: String) -> void:
		if value != texture_res_name:
			texture_res_name = value
			_changed()


func set_texture_res_name_hd(value: String) -> void:
		if value != texture_res_name_hd:
			texture_res_name_hd = value
			_changed()


func set_texture_res_name_ipad(value: String) -> void:
		if value != texture_res_name:
			texture_res_name = value
			_changed()


func set_image_name(value: StringName) -> void:
		if value != name:
			name = value
			_changed()


func _changed() -> void:
	if name.is_empty():
		texture = null
		return
	var selected_name: String
	var is_hd := false
	if not Engine.is_editor_hint():
		if not texture_res_name_ipad.is_empty() and _ecGraphics.instance().content_scale_size_mode == 3:
			selected_name = texture_res_name_ipad
		elif not texture_res_name_hd.is_empty() and _native.g_content_scale_factor == 2.0:
			selected_name = texture_res_name_hd
			is_hd = true
		else:
			selected_name = texture_res_name
	else:
		selected_name = texture_res_name
	if selected_name.is_empty():
		texture = null
		return
	var texture_res: _ecTextureRes
	var selected_path := _native.get_path_alias(selected_name, "")
	if not selected_path.is_empty():
		texture_res = load(_native.get_path_alias(selected_name, "")) as _ecTextureRes
	if texture_res == null and Engine.is_editor_hint(): # in the editor, the situation is considered where only _hd variant exists
		selected_path = _native.get_path_alias(texture_res_name_hd, "")
		if not selected_path.is_empty():
			texture_res = load(selected_path) as _ecTextureRes
	if texture_res == null:
		texture = null
		return
	var attr: _ecTextureRect = texture_res.images.get(name)
	if attr == null:
		texture = null
		return
	var ec_texture := _ecTexture.new()
	ec_texture.set_texture_name(texture_res.texture_name)
	if ec_texture.texture != null:
		texture = ec_texture
		texture_scale = 2.0 if is_hd else 1.0
		region = Rect2(attr.x, attr.y, attr.w, attr.h)
		ref = Vector2(attr.refx, attr.refy)
	else:
		texture = null


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	pos -= ref / texture_scale
	var src_rect := region
	src_rect.position /= texture_scale
	src_rect.size /= texture_scale
	texture.draw_rect_region(to_canvas_item, Rect2(pos, src_rect.size), src_rect, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	rect.position -= ref / texture_scale
	var src_rect := region
	src_rect.position /= texture_scale
	src_rect.size /= texture_scale
	if tile:
		src_rect.size *= rect.size / src_rect.size
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, not tile)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if texture == null:
		return
	rect.position -= ref / texture_scale
	src_rect.position = src_rect.position * texture_scale + region.position
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
