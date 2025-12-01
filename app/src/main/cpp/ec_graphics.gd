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
## viewport is modified to achieve the same effect.

const _ecLine = preload("res://app/src/main/cpp/ec_line.gd")
const _ecTriple = preload("res://app/src/main/cpp/ec_line.gd")
const _ecQuad = preload("res://app/src/main/cpp/ec_quad.gd")
const _Texture_Cache_Prefix = "res://app/src/main/cpp/scene_system_resource/texture_cache/"

static var _instance := _ecGraphics.new()

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
var _occupied_buffer := 0
var _fade_color := Color.BLACK
var _rendering_canvas_item: CanvasItem
var _blend_material: Array[CanvasItemMaterial]

static func instance() -> _ecGraphics:
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
	var material_add := CanvasItemMaterial.new()
	material_add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_blend_material.append(material_add)
	var material_mix := CanvasItemMaterial.new()
	material_mix.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	_blend_material.append(material_mix)
	var material_mul := CanvasItemMaterial.new()
	material_mul.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	_blend_material.append(material_mul)
	var window := (Engine.get_main_loop() as SceneTree).root
	await window.tree_entered
	window.content_scale_factor = g_content_scale_factor
	var window_content_x := content_scale_width * g_content_scale_factor
	var window_content_y := content_scale_height * g_content_scale_factor
	window.content_scale_size = Vector2i(window_content_x as int, window_content_y as int)
	_Wc2Activity.get_game_view().size = Vector2(content_scale_width, content_scale_height)
	_Wc2Activity.get_game_view().position = Vector2.ZERO


func shutdown() -> void:
	_blend_material.clear()


func _set_orientation(value: int) -> void:
	orientation = value
	if value > 1:
		orientated_content_scale_width = _content_scale_height
		orientated_content_scale_height = _content_scale_width
	else:
		orientated_content_scale_width = _content_scale_width
		orientated_content_scale_height = _content_scale_height


func create_texture_with_string(a1: String, a2: String, a3: int, a4: int, width: int, height: int) -> _ecTexture:
	var r_width:Array[int] = [width]
	var r_height:Array[int] = [height]
	var r_texture:Array[Texture] = []
	if ec_texture_with_string(a1, a2, a3, a4, r_width, r_height, r_texture):
		var ec_texture := _ecTexture.new()
		ec_texture.size_override = Vector2i(r_width[0], r_height[0])
		ec_texture.texture = r_texture[0]
		bind_texture(ec_texture)
		return ec_texture
	else:
		return null


## Other varients of LoadTexture are omitted.
func load_texture(texture_name: String) -> _ecTexture:
	if ResourceLoader.has_cached(_Texture_Cache_Prefix + texture_name):
		return ResourceLoader.get_cached_ref(_Texture_Cache_Prefix + texture_name)
	var ec_texture := ec_texture_load(texture_name)
	ec_texture.res_scale = 1.0
	#ec_texture.take_over_path(_Texture_Cache_Prefix + texture_name) # Use the resource cache to cache ecTexture
	return ec_texture


func free_texture(_texture_name: StringName) -> void:
	# nothing to do
	pass


func get_rendering_canvas_item() -> CanvasItem:
	return _rendering_canvas_item


func render_begin(canvas_item: CanvasItem = _Wc2Activity.get_game_view()):
	_rendering_canvas_item = canvas_item
	_bound_texture = null
	if _blend_mode == 1:
		canvas_item.material = _blend_material[0]
	elif _blend_mode == 3:
		canvas_item.material = _blend_material[2]
	else:
		canvas_item.material = _blend_material[1]


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


func set_blend_mode(value: int):
	if _rendering_canvas_item == null:
		return
	if _blend_mode != value:
		_flush()
		if _blend_mode == 1:
			_rendering_canvas_item.material = _blend_material[0]
		elif _blend_mode == 3:
			_rendering_canvas_item.material = _blend_material[2]
		else:
			_rendering_canvas_item.material = _blend_material[1]
		_blend_mode = value


func bind_texture(ec_texture: _ecTexture):
	if _rendering_canvas_item == null:
		return
	var texture = ec_texture.texture
	if texture != _bound_texture:
		_flush()
		_bound_texture = texture


func _render_line(line: _ecLine):
	if _rendering_canvas_item == null:
		return
	if _render_shape != 2 or _occupied_buffer > 3998:
		_flush()
		_render_shape = 2
	# Leave batching to be handled by the engine
	_rendering_canvas_item.draw_primitive(line.points, line.colors, line.uvs, _bound_texture)
	_occupied_buffer += 2


func _render_triple(triple: _ecTriple):
	if _rendering_canvas_item == null:
		return
	if _render_shape != 3 or _occupied_buffer > 3997:
		_flush()
		_render_shape = 3
	# Leave batching to be handled by the engine
	_rendering_canvas_item.draw_primitive(triple.points, triple.colors, triple.uvs, _bound_texture)
	_occupied_buffer += 3


func render_quad(quad: _ecQuad):
	if _rendering_canvas_item == null:
		return
	if _render_shape != 3 or _occupied_buffer > 3994:
		_flush()
		_render_shape = 3
	# Leave batching to be handled by the engine
	_rendering_canvas_item.draw_primitive(quad.points, quad.colors, quad.uvs, _bound_texture)
	_occupied_buffer += 6


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


func fade(alpha: float):
	if _rendering_canvas_item == null:
		return
	var color := _fade_color
	color.a = alpha
	# Note: fade is properly applied only if view_point is at 0.0, 0.0. This is bad but is consistent with the original game code.
	render_rect(0.0, 0.0, orientated_content_scale_width, orientated_content_scale_height, color)


func _flush():
	# Leave batching to be handled by the engine
	_occupied_buffer = 0
