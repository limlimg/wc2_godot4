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

const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")
const _Wc2Activity = preload("res://app/src/main/java/com/easytech/wc2/wc2_activity.gd")
const _ecLine = preload("res://app/src/main/cpp/ec_line.gd")
const _ecTriple = preload("res://app/src/main/cpp/ec_line.gd")
const _ecQuad = preload("res://app/src/main/cpp/ec_quad.gd")

static var _instance := new()

#var _width_multiplier: float
#var _height_multiplier: float
var _content_scale_width: int
var _content_scale_height: int
var _orientated_content_scale_width: int
var _orientated_content_scale_height: int
var _orientation: int
var _content_scale_size_mode: int
var _blend_mode := 2
var _render_shape := 3
var _bound_texture: Texture2D
var _occupied_buffer := 0
var _fade_color := Color.BLACK
var _render_target: CanvasItem
var _blend_material: Array[CanvasItemMaterial]

static func instance() -> _ecGraphics:
	return _instance


func init(content_scale_width: int, content_scale_height: int, orientation: int, _view_width: int, _view_height: int) -> void:
	_content_scale_width = content_scale_width
	_content_scale_height = content_scale_height
	_orientation = orientation
	#if view_width == 1 and view_height == 1:
		#_width_multiplier = 1.0
		#_height_multiplier = 1.0
	#else:
		#_width_multiplier = view_width / (canvas_width * g_content_scale_factor)
		#_height_multiplier = view_height / (canvas_height * g_content_scale_factor)
	var window := (Engine.get_main_loop() as SceneTree).root
	window.content_scale_factor = g_content_scale_factor
	var window_content_x := content_scale_width * g_content_scale_factor
	var window_content_y := content_scale_height * g_content_scale_factor
	window.content_scale_size = Vector2i(window_content_x as int, window_content_y as int)
	_Wc2Activity.get_game_view().size = Vector2(content_scale_width, content_scale_height)
	_Wc2Activity.get_game_view().position = Vector2.ZERO
	if orientation <= 1:
		_orientated_content_scale_width = content_scale_width
		_orientated_content_scale_height = content_scale_height
	else:
		_orientated_content_scale_width = content_scale_height
		_orientated_content_scale_height = content_scale_width
	if content_scale_width > 320:
		if content_scale_height > 640 :
			_content_scale_size_mode = 3
		else:
			_content_scale_size_mode = 2
	else:
		_content_scale_size_mode = 1
	var material_add := CanvasItemMaterial.new()
	material_add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_blend_material.append(material_add)
	var material_mix := CanvasItemMaterial.new()
	material_mix.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	_blend_material.append(material_mix)
	var material_mul := CanvasItemMaterial.new()
	material_mul.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	_blend_material.append(material_mul)


func shutdown() -> void:
	_blend_material.clear()


func set_orientation(value: int) -> void:
	_orientation = value
	if value > 1:
		_orientated_content_scale_width = _content_scale_height
		_orientated_content_scale_height = _content_scale_width
	else:
		_orientated_content_scale_width = _content_scale_width
		_orientated_content_scale_height = _content_scale_height


func create_texture(_1: int, _2: int) -> _ecTexture:
	# Unimplemented and unused in original code
	return null


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
func load_texture(texture_name: String) -> Texture2D:
	# Caching of the texture is handled by ResourceLoader.
	var r_texture:Array[Texture2D] = []
	if ec_texture_load(texture_name, [], [], r_texture):
		return r_texture[0]
	else:
		return null


func free_texture(_texture_name: StringName) -> void:
	# nothing to do
	pass


func render_begin(target: CanvasItem = _Wc2Activity.get_game_view()):
	_render_target = target
	_bound_texture = null
	if _blend_mode == 1:
		target.material = _blend_material[0]
	elif _blend_mode == 3:
		target.material = _blend_material[2]
	else:
		target.material = _blend_material[1]


func render_end():
	_flush()
	_render_target = null


func set_view_point(x: float, y: float, scale: float):
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	if _render_target == null:
		return
	_flush()
	var transform = Transform2D.IDENTITY
	if _orientation == 3:
		transform = transform.rotated_local(deg_to_rad(90.0))
		transform = transform.translated_local(Vector2(0.0, -_content_scale_width))
	elif _orientation == 2:
		transform = transform.rotated_local(deg_to_rad(-90.0))
		transform = transform.translated_local(Vector2(-_content_scale_height, 0.0))
	transform = transform.scaled_local(Vector2(scale, scale))
	#transform = transform.scaled_local(Vector2(_width_multiplier, _height_multiplier))
	transform = transform.translated_local(Vector2(-x, -y))
	_render_target.draw_set_transform_matrix(transform)


func set_blend_mode(value: int):
	if _render_target == null:
		return
	if _blend_mode != value:
		_flush()
		if _blend_mode == 1:
			_render_target.material = _blend_material[0]
		elif _blend_mode == 3:
			_render_target.material = _blend_material[2]
		else:
			_render_target.material = _blend_material[1]
		_blend_mode = value


func bind_texture(texture: _ecTexture):
	if _render_target == null:
		return
	if texture != _bound_texture:
		_flush()
		if texture is _ecTexture:
			_bound_texture = texture.texture # reduce a layer of GDScript when drawing
		else:
			_bound_texture = texture


func render_line(line: _ecLine):
	if _render_target == null:
		return
	if _render_shape != 2 or _occupied_buffer > 3998:
		_flush()
		_render_shape = 2
	# Leave batching to be handled by the engine
	_render_target.draw_primitive(line.points, line.colors, line.uvs, _bound_texture)
	_occupied_buffer += 2


func render_triple(triple: _ecTriple):
	if _render_target == null:
		return
	if _render_shape != 3 or _occupied_buffer > 3997:
		_flush()
		_render_shape = 3
	# Leave batching to be handled by the engine
	_render_target.draw_primitive(triple.points, triple.colors, triple.uvs, _bound_texture)
	_occupied_buffer += 3


func render_quad(quad: _ecQuad):
	if _render_target == null:
		return
	if _render_shape != 3 or _occupied_buffer > 3994:
		_flush()
		_render_shape = 3
	# Leave batching to be handled by the engine
	_render_target.draw_primitive(quad.points, quad.colors, quad.uvs, _bound_texture)
	_occupied_buffer += 6


func render_rect(x: float, y: float, width: float, height: float, color: Color):
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	if _render_target == null:
		return
	_flush()
	_render_target.draw_rect(Rect2(x, y, width, height), color)


func render_circle(x: float, y: float, radius: float, color: Color):
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	if _render_target == null:
		return
	_flush()
	_render_target.draw_circle(Vector2(x, y), radius, color)


func fade(alpha: float):
	if _render_target == null:
		return
	var color := _fade_color
	color.a = alpha
	# Note: fade is properly applied only if view_point is at 0.0, 0.0. This is bad but is consistent with the original game code.
	render_rect(0.0, 0.0, _orientated_content_scale_width, _orientated_content_scale_height, color)


func _flush():
	# Leave batching to be handled by the engine
	_occupied_buffer = 0
