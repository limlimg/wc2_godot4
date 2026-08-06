@tool
class_name ecGraphics
extends Object

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

const _BATCH_LIMIT = 96

static var _instance := new()

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
var _indices: PackedInt32Array
var _points: PackedVector2Array
var _colors: PackedColorArray
var _uvs: PackedVector2Array
var _count: int
var fade_color: Color
var _texture_cache: Dictionary[String, WeakRef]
var _rendering_canvas_item: RID
var _material_add := CanvasItemMaterial.new()
var _material_mix := CanvasItemMaterial.new()
var _material_mul := CanvasItemMaterial.new()

static func instance() -> ecGraphics:
	return _instance


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
	_material_add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_material_mix.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	_material_mul.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	_indices.resize(_BATCH_LIMIT)
	_points.resize(_BATCH_LIMIT)
	_colors.resize(_BATCH_LIMIT)
	_uvs.resize(_BATCH_LIMIT)
	var window := (Engine.get_main_loop() as SceneTree).root
	await window.ready
	var window_content_x = content_scale_width * AppDelegate.g_content_scale_factor
	var window_content_y = content_scale_height * AppDelegate.g_content_scale_factor
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


func create_texture_with_string(string: String, font_name: String, font_size: int, alignment: int, width: int, height: int) -> ecTexture:
	var texture = AppDelegate.ec_texture_with_string(string, font_name, font_size, alignment, width, height)
	if texture != null:
		return texture
	else:
		return null


## Other varients of LoadTexture are omitted.
func load_texture(texture_name: String) -> ecTexture:
	if _texture_cache.has(texture_name) and _texture_cache[texture_name].get_ref() != null:
		return _texture_cache[texture_name].get_ref()
	var ec_texture = EC2dAppDelegate.ec_texture_load(texture_name)
	if ec_texture != null:
		_texture_cache[texture_name] = weakref(ec_texture)
	return ec_texture


func free_texture(texture_name: StringName) -> void:
	if _texture_cache.has(texture_name) and _texture_cache[texture_name].get_ref() == null:
		_texture_cache.erase(texture_name)


func render_begin(canvas_item: RID):
	_rendering_canvas_item = canvas_item
	_bound_texture = null
	match _blend_mode:
		1:
			RenderingServer.canvas_item_set_material(canvas_item, _material_add.get_rid())
		3:
			RenderingServer.canvas_item_set_material(canvas_item, _material_mul.get_rid())
		_:
			RenderingServer.canvas_item_set_material(canvas_item, _material_mix.get_rid())
	RenderingServer.canvas_item_clear(canvas_item)


func render_end():
	_flush()
	_rendering_canvas_item = RID()


func set_view_point(x: float, y: float, scale: float):
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	_flush()
	if not _rendering_canvas_item.is_valid():
		return
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
	RenderingServer.canvas_item_add_set_transform(_rendering_canvas_item, transform)


func bind_texture(texture):
	if texture is ecTexture:
		texture = texture.texture
	if texture != _bound_texture:
		_flush()
		_bound_texture = texture


func set_blend_mode(value: int) -> void:
	if value != _blend_mode:
		_blend_mode = value
		if not _rendering_canvas_item.is_valid():
			return
		match _blend_mode:
			1:
				RenderingServer.canvas_item_set_material(_rendering_canvas_item, _material_add.get_rid())
			3:
				RenderingServer.canvas_item_set_material(_rendering_canvas_item, _material_mul.get_rid())
			_:
				RenderingServer.canvas_item_set_material(_rendering_canvas_item, _material_mix.get_rid())


func render_line(line: ecLine):
	if _render_shape != 2 or _count > _BATCH_LIMIT - 2:
		_flush()
		_render_shape = 2
	for i in 2:
		_points[_count] = line.points[i]
		_colors[_count] = line.colors[i]
		_count += 1


func render_triple(triple: ecTriple):
	if _render_shape != 3 or _count > _BATCH_LIMIT - 3:
		_flush()
		_render_shape = 3
	for i in 3:
		_indices[_count] = _count
		_points[_count] = triple.points[i]
		_colors[_count] = triple.colors[i]
		_uvs[_count] = triple.uvs[i]
		_count += 1


func render_quad(quad: ecQuad):
	if _render_shape != 3 or _count > _BATCH_LIMIT - 6:
		_flush()
		_render_shape = 3
	for i in [1, 0, 2, 0, 3, 2]:
		_indices[_count] = _count
		_points[_count] = quad.points[i]
		_colors[_count] = quad.colors[i]
		_uvs[_count] = quad.uvs[i]
		_count += 1


func render_rect(x: float, y: float, width: float, height: float, color: Color):
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	_flush()
	if not _rendering_canvas_item.is_valid():
		return
	RenderingServer.canvas_item_add_rect(_rendering_canvas_item, Rect2(x, y, width, height), color)


func render_circle(x: float, y: float, radius: float, color: Color):
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	_flush()
	if not _rendering_canvas_item.is_valid():
		return
	RenderingServer.canvas_item_add_circle(_rendering_canvas_item, Vector2(x, y), radius, color)


func render_text(font: Font, x: float, y: float, text: String, alignment: HorizontalAlignment, font_size: int, color: Color) -> void:
	if not _rendering_canvas_item.is_valid():
		return
	_flush()
	font.draw_string(_rendering_canvas_item, Vector2(x, y), text, alignment, -1, font_size, color)


func fade(alpha: float):
	if not _rendering_canvas_item.is_valid():
		return
	var color := Color(fade_color, alpha)
	var view_size := (Engine.get_main_loop() as SceneTree).root.get_visible_rect().size
	render_rect(0.0, 0.0, view_size.x, view_size.y, color)


func _flush():
	if _count > 0:
		if _render_shape == 2:
			RenderingServer.canvas_item_add_multiline(_rendering_canvas_item, _points.slice(0, _count), _colors.slice(0, _count))
		elif _render_shape == 3:
			if _bound_texture != null:
				@warning_ignore("integer_division")
				RenderingServer.canvas_item_add_triangle_array(_rendering_canvas_item, _indices, _points, _colors, _uvs, [], [], _bound_texture.get_rid(), _count / 3)
		_count = 0
	# The engine is too aggresive in batching that a second call to draw_primitive ignores the texture parameter.
	# The following clams it down before changing texture. 
	#_rendering_canvas_item.draw_rect(Rect2(), Color.TRANSPARENT)
