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
## ecGraphics.

const _Profile = preload("res://app/src/main/cpp/runtime_resource/ec_texture_profile.gd")
const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")

@export
var profile: _Profile:
	set(value):
		if value != profile:
			if profile != null:
				profile.changed.disconnect(_profile_changed)
			profile = value
			if profile != null:
				_profile_changed()
				profile.changed.connect(_profile_changed)


var size_override: Vector2:
	set(value):
		if value != size_override:
			size_override = value
			changed.emit()


var texture: Texture2D:
	set(value):
		if value != texture:
			texture = value
			changed.emit()


func _profile_changed() -> void:
	if profile.name.is_empty():
		texture = null
		return
	var selected_name: String
	if not Engine.is_editor_hint():
		var graphics := _ecGraphics.instance()
		if graphics.content_scale_size_mode == 3:
			selected_name = profile.name_ipad
		else:
			var w := graphics.orientated_content_scale_width
			if w > 568.0:
				selected_name = profile.name_640h
			elif w > 534.0:
				selected_name = profile.name_568h
			elif w == 534.0:
				selected_name = profile.name_534h
			elif w == 512.0:
				selected_name = profile.name_512h
		if selected_name.is_empty():
			selected_name = profile.name
		var selected_texture := graphics.load_texture(selected_name)
		if selected_texture is _ecTexture:
			texture = selected_texture.texture
			size_override = selected_texture.size_override
		else:
			texture = selected_texture
			size_override = selected_texture.get_size()
	else:
		selected_name = _native.get_path_alias(profile.name, "")
		if not selected_name.is_empty():
			var selected_texture := load(selected_name) as Texture2D
			texture = selected_texture
			if texture != null:
				size_override = selected_texture.get_size()
		else: # in the editor, the situation is considered where only @2x variant exists
			selected_name = _native.get_2x_path(profile.name, "")
			if selected_name.is_empty():
				texture = null
				return
			texture = load(selected_name) as Texture2D
			if texture != null:
				size_override = texture.get_size() / 2.0


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	var size := size_override
	texture.draw_rect(to_canvas_item, Rect2(pos, size), false, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	var src_rect := Rect2(Vector2.ZERO, texture.get_size())
	if tile:
		src_rect.size *= rect.size / size_override
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, not tile)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if texture == null:
		return
	src_rect.position *= texture.get_size() / size_override
	src_rect.size *= texture.get_size() / size_override
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	if texture == null:
		return 0
	return size_override.x as int


func _get_height() -> int:
	if texture == null:
		return 0
	return size_override.y as int


func _has_alpha() -> bool:
	if texture == null:
		return false
	return texture.has_alpha()
