extends "res://app/src/main/cpp/native-lib.gd"

## In the original game code, ecGraphics is responsible for maintaining screen
## size, and loading and drawing textures.
## 
## In this Godot port, it draws to the CanvasItem referred to by _render_target,
## which is the ecGLSurfaceView created by Wc2Activity.
## 
## ecGraphics in the original game code implements batching as described in
## Godot document. Currently this is handled by the engine and therefore not by
## this class.

const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")
const _Wc2Activity = preload("res://app/src/main/java/com/easytech/wc2/wc2_activity.gd")
const _ecLine = preload("res://app/src/main/cpp/ec_line.gd")
const _ecTriple = preload("res://app/src/main/cpp/ec_line.gd")
const _ecQuad = preload("res://app/src/main/cpp/ec_quad.gd")

static var _instance := new()

var _width_multiplier: float
var _height_multiplier: float
var _canvas_width: int
var _canvas_height: int
var _orientated_canvas_width: int
var _orientated_canvas_height: int
var _orientation: int
var _canvas_size_mode: int
var _blend_mode := 2
var _render_shape := 3
var _bound_texture: Texture2D
var _occupied_buffer := 0
var _fade_color := Color.BLACK
var _render_target: CanvasItem

static func instance() -> _ecGraphics:
	return _instance


func init(canvas_width: int, canvas_height: int, orientation: int, view_width: int, view_height: int) -> void:
	_canvas_width = canvas_width
	_canvas_height = canvas_height
	_orientation = orientation
	if view_width == 1 and view_height == 1:
		_width_multiplier = 1.0
		_height_multiplier = 1.0
	else:
		_width_multiplier = view_width / (canvas_width * g_content_scale_factor)
		_height_multiplier = view_height / (canvas_height * g_content_scale_factor)
	if orientation <= 1:
		_orientated_canvas_width = canvas_width
		_orientated_canvas_height = canvas_height
	else:
		_orientated_canvas_width = canvas_height
		_orientated_canvas_height = canvas_width
	if canvas_width > 320:
		if canvas_height > 640 :
			_canvas_size_mode = 3
		else:
			_canvas_size_mode = 2
	else:
		_canvas_size_mode = 1
	_render_target = _Wc2Activity.get_game_view()


func shutdown() -> void:
	_render_target = null


func set_orientation(value: int) -> void:
	_orientation = value
	if value > 1:
		_orientated_canvas_width = _canvas_height
		_orientated_canvas_height = _canvas_width
	else:
		_orientated_canvas_width = _canvas_width
		_orientated_canvas_height = _canvas_height


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


func render_begin():
	_bound_texture = null


func render_end():
	_flush()


func set_view_point(x: float, y: float, scale: float):
	_flush()
	var transform = Transform2D.IDENTITY
	if _orientation == 3:
		transform = transform.rotated_local(deg_to_rad(90.0))
		transform = transform.translated_local(Vector2(0.0, -_canvas_width * g_content_scale_factor))
	elif _orientation == 2:
		transform = transform.rotated_local(deg_to_rad(-90.0))
		transform = transform.translated_local(Vector2(-_canvas_height * g_content_scale_factor, 0.0))
	transform = transform.scaled_local(Vector2(scale, scale))
	transform = transform.scaled_local(Vector2(_width_multiplier, _height_multiplier))
	transform = transform.translated_local(Vector2(-x * g_content_scale_factor, -y * g_content_scale_factor))
	_render_target.draw_set_transform_matrix(transform)


func set_blend_mode(value: int):
	if _blend_mode != value:
		_flush()
		if value == 1:
			(_render_target.material as CanvasItemMaterial).blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		elif value == 3:
			(_render_target.material as CanvasItemMaterial).blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
		else:
			(_render_target.material as CanvasItemMaterial).blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		_blend_mode = value


func bind_texture(texture: _ecTexture):
	if texture != _bound_texture:
		_flush()
		_bound_texture = texture


func render_line(line: _ecLine):
	if _render_shape != 2 or _occupied_buffer > 3998:
		_flush()
		_render_shape = 2
	_render_target.draw_primitive(line.points, line.colors, line.uvs, _bound_texture.texture)
	_occupied_buffer += 2


func render_triple(triple: _ecTriple):
	if _render_shape != 3 or _occupied_buffer > 3997:
		_flush()
		_render_shape = 3
	_render_target.draw_primitive(triple.points, triple.colors, triple.uvs, _bound_texture.texture)
	_occupied_buffer += 3


func render_quad(quad: _ecQuad):
	if _render_shape != 3 or _occupied_buffer > 3994:
		_flush()
		_render_shape = 3
	_render_target.draw_primitive(quad.points, quad.colors, quad.uvs, _bound_texture.texture)
	_occupied_buffer += 6


func render_rect(x: float, y: float, width: float, height: float, color: Color):
	_flush()
	_render_target.draw_rect(Rect2(x * g_content_scale_factor, y * g_content_scale_factor, width * g_content_scale_factor, height * g_content_scale_factor), color)


func render_circle(x: float, y: float, radius: float, color: Color):
	_flush()
	_render_target.draw_circle(Vector2(x * g_content_scale_factor, y * g_content_scale_factor), radius * g_content_scale_factor, color)


func fade(alpha: float):
	var color := _fade_color
	color.a = alpha
	# Note: fade is properly applied only if view_point is at 0.0, 0.0. This is bad but is consistent with the original game code.
	render_rect(0.0, 0.0, _orientated_canvas_width, _orientated_canvas_height, color)


func _flush():
	_occupied_buffer = 0
