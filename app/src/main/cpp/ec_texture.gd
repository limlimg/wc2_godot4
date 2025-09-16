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

@export
var size_override: Vector2:
	set(value):
		if value != size_override:
			size_override = value
			changed.emit()


var res_scale: float

@export
var texture: Texture2D:
	set(value):
		if value != texture:
			texture = value
			changed.emit()


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	var size := size_override
	texture.draw_rect(to_canvas_item, Rect2(pos, size), false, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if texture == null:
		return
	src_rect.position *= texture.get_size() / size_override
	src_rect.size *= texture.get_size() / size_override
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	return size_override.x


func _get_height() -> int:
	return size_override.y


func _has_alpha() -> bool:
	if texture == null:
		return false
	return texture.has_alpha()
