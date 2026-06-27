@tool
extends "res://app/src/main/cpp/native-lib.gd"

## In the original game code, ecGraphics is responsible for loading textures and
## drawing them. It calls native GL functions to draw on the ecGLSurfaceView
## created by Wc2Activity. It also maintains a local coordinate system so that
## the rest of the game only deals with a limit set of screen sizes.
## 
## In Godot, SceneTree is the usual way to draw on screen, backed by custom
## drawing which allows drawing with code. This class wraps custom drawing apis
## to provide the same interface as in the original game code. To use it, pass
## the CanvasItem to draw on to render_begin. Make sure to do this during the
## _draw callback of the CanvasItem. For the local coordinate system, the root
## viewport is modified to achieve the same effect. SetBlendMode is not
## implemented because it is unused in the original code and complicated to
## implement using Godot's API (require multiple canvas items).

const _ecLine = preload("res://app/src/main/cpp/ec_line.gd")
const _ecTriple = preload("res://app/src/main/cpp/ec_line.gd")
const _ecQuad = preload("res://app/src/main/cpp/ec_quad.gd")

#var _width_multiplier: float
#var _height_multiplier: float
var _content_scale_width: int
var _content_scale_height: int
var orientated_content_scale_width: int
var orientated_content_scale_height: int
var orientation: int
var content_scale_size_mode: int
var _blend_mode := 2
var _render_shape := 3
var _bound_texture: Texture2D
var fade_color: Color
var _texture_cache: Dictionary[String, WeakRef]
var _rendering_canvas_item: CanvasItem

static func instance() -> _ecGraphics:
	return ecGraphics


func init(content_scale_width: int, content_scale_height: int, _orientation: int, _view_width: int, _view_height: int) -> void:
	# initialized early in _init
	_content_scale_width = content_scale_width
	_content_scale_height = content_scale_height
	orientation = _orientation
	# scaling content to window is done by the root viewport
	#if view_width == 1 and view_height == 1:
		#_width_multiplier = 1.0
		#_height_multiplier = 1.0
	#else:
		#_width_multiplier = view_width / (canvas_width * g_content_scale_factor)
		#_height_multiplier = view_height / (canvas_height * g_content_scale_factor)
	if orientation <= 1:
		orientated_content_scale_width = content_scale_width
		orientated_content_scale_height = content_scale_height
	else:
		orientated_content_scale_width = content_scale_height
		orientated_content_scale_height = content_scale_width
	if content_scale_width > 320:
		if content_scale_height > 640 :
			content_scale_size_mode = 3
		else:
			content_scale_size_mode = 2
	else:
		content_scale_size_mode = 1
	var window := (Engine.get_main_loop() as SceneTree).root
	await window.tree_entered
	window.content_scale_factor = g_content_scale_factor
	var window_content_x := content_scale_width * g_content_scale_factor
	var window_content_y := content_scale_height * g_content_scale_factor
	window.content_scale_size = Vector2i(window_content_x as int, window_content_y as int)


func shutdown() -> void:
	# nothing to do
	pass


func _set_orientation(value: int) -> void:
	orientation = value
	if value > 1:
		orientated_content_scale_width = _content_scale_height
		orientated_content_scale_height = _content_scale_width
	else:
		orientated_content_scale_width = _content_scale_width
		orientated_content_scale_height = _content_scale_height


func create_texture_with_string(string: String, font_name: String, font_size: int, alignment: int, width: int, height: int) -> _ecTexture:
	var texture = ec_texture_with_string(string, font_name, font_size, alignment, width, height)
	if texture != null:
		return texture
	else:
		return null


## Other varients of LoadTexture are omitted.
func load_texture(texture_name: String) -> _ecTexture:
	if _texture_cache.has(texture_name) and _texture_cache[texture_name].get_ref() != null:
		return _texture_cache[texture_name].get_ref()
	var ec_texture := ec_texture_load(texture_name)
	if ec_texture != null:
		_texture_cache[texture_name] = weakref(ec_texture)
	return ec_texture


func free_texture(texture_name: StringName) -> void:
	if _texture_cache.has(texture_name) and _texture_cache[texture_name].get_ref() == null:
		_texture_cache.erase(texture_name)


func get_rendering_canvas_item() -> CanvasItem:
	return _rendering_canvas_item


func render_begin(canvas_item: CanvasItem = _Wc2Activity.get_game_view()):
	_rendering_canvas_item = canvas_item
	_bound_texture = null
	if _blend_mode != 2:
		if canvas_item.material == null:
			canvas_item.material = CanvasItemMaterial.new()
		match _blend_mode:
			1:
				canvas_item.material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			3:
				canvas_item.material.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
			_:
				canvas_item.material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX


func render_end():
	_flush()
	_rendering_canvas_item = null


func set_view_point(x: float, y: float, scale: float):
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	if _rendering_canvas_item == null:
		return
	_flush()
	var transform = Transform2D.IDENTITY
	if orientation == 3:
		transform = transform.rotated_local(deg_to_rad(90.0))
		transform = transform.translated_local(Vector2(0.0, -_content_scale_width))
	elif orientation == 2:
		transform = transform.rotated_local(deg_to_rad(-90.0))
		transform = transform.translated_local(Vector2(-_content_scale_height, 0.0))
	transform = transform.scaled_local(Vector2(scale, scale))
	#transform = transform.scaled_local(Vector2(_width_multiplier, _height_multiplier))
	transform = transform.translated_local(Vector2(-x, -y))
	_rendering_canvas_item.draw_set_transform_matrix(transform)


func bind_texture(texture: Texture2D):
	if _rendering_canvas_item == null:
		return
	if texture is _ecTexture:
		texture = texture.texture
	if texture != _bound_texture:
		_flush()
		_bound_texture = texture


func set_blend_mode(value: int) -> void:
	if _rendering_canvas_item == null:
		return
	if _rendering_canvas_item.material == null:
		_rendering_canvas_item.material = CanvasItemMaterial.new()
	if value != _blend_mode:
		_blend_mode = value
		match value:
			1:
				_rendering_canvas_item.material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			3:
				_rendering_canvas_item.material.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
			_:
				_rendering_canvas_item.material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX


func render_line(line: _ecLine):
	if _rendering_canvas_item == null:
		return
	if _render_shape != 2:
		_flush()
		_render_shape = 2
	# Leave batching to be handled by the engine
	_rendering_canvas_item.draw_primitive(line.points, line.colors, line.uvs, _bound_texture)


func render_triple(triple: _ecTriple):
	if _rendering_canvas_item == null:
		return
	if _render_shape != 3:
		_flush()
		_render_shape = 3
	# Leave batching to be handled by the engine
	_rendering_canvas_item.draw_primitive(triple.points, triple.colors, triple.uvs, _bound_texture)


func render_quad(quad: _ecQuad):
	if _rendering_canvas_item == null:
		return
	if _render_shape != 3:
		_flush()
		_render_shape = 3
	# Leave batching to be handled by the engine
	_rendering_canvas_item.draw_primitive(quad.points, quad.colors, quad.uvs, _bound_texture)


func render_rect(x: float, y: float, width: float, height: float, color: Color):
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	if _rendering_canvas_item == null:
		return
	_flush()
	_rendering_canvas_item.draw_rect(Rect2(x, y, width, height), color)


func render_circle(x: float, y: float, radius: float, color: Color):
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	if _rendering_canvas_item == null:
		return
	_flush()
	_rendering_canvas_item.draw_circle(Vector2(x, y), radius, color)


func render_text(text: TextParagraph, x: float, y: float, color: Color) -> void:
	if _rendering_canvas_item == null:
		return
	_flush()
	text.draw(_rendering_canvas_item.get_canvas_item(), Vector2(x, y), color)


func fade(alpha: float):
	if _rendering_canvas_item == null:
		return
	var color := Color(fade_color, alpha)
	var trans_inv := _rendering_canvas_item.get_global_transform_with_canvas().affine_inverse()
	var view_size := get_viewport().get_visible_rect().size
	var v0 := trans_inv * Vector2.ZERO
	var v1 := trans_inv * Vector2(view_size.x, 0.0)
	var v2 := trans_inv * Vector2(view_size.x, view_size.y)
	var v3 := trans_inv * Vector2(0.0, view_size.y)
	var pos := Vector2(min(v0.x, v1.x, v2.x, v3.x), min(v0.y, v1.y, v2.y, v3.y))
	var size := Vector2(max(v0.x, v1.x, v2.x, v3.x), max(v0.y, v1.y, v2.y, v3.y)) - pos
	render_rect(pos.x, pos.y, size.x, size.y, color)


func _flush():
	# The engine is too aggresive in batching that a second call to draw_primitive ignores the texture parameter.
	# The following clams it down before changing texture. 
	_rendering_canvas_item.draw_rect(Rect2(), Color.TRANSPARENT)
