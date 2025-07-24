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
var size_override: Vector2i

@export
var texture: Texture2D

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	texture.draw_rect(to_canvas_item, Rect2(pos, size_override), false, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if texture == null:
		return
	texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if texture == null:
		return
	src_rect.position = texture.get_size() / Vector2(size_override) * src_rect.position
	src_rect.size = texture.get_size() / Vector2(size_override) * src_rect.size
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	return size_override.x


func _get_height() -> int:
	return size_override.y


func _has_alpha() -> bool:
	if texture == null:
		return false
	return texture.has_alpha()


#func _is_pixel_opaque(x: int, y: int) -> bool:
	#if texture == null:
		#return false
	#@warning_ignore("integer_division")
	#return texture._is_pixel_opaque(x * texture.get_width() / size_override.x, y * texture.get_height() / size_override.y)
