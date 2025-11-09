
const _ecQuad = preload("res://app/src/main/cpp/ec_quad.gd")
const _ecImageAttr = preload("res://app/src/main/cpp/ec_image_attr.gd")
const _ecTextureRect = preload("res://app/src/main/cpp/ec_texture_rect.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")
const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")

var _texture: _ecTexture
var _x: float
var _y: float
var _w: float
var _h: float
var _refx: float
var _refy: float
var _texture_w: float
var _texture_h: float
var _quad := _ecQuad.new()
var _blend_mode: int
var _flip_x: bool
var _flip_y: bool
var _flip_ref: bool

func _init(texture_or_attr, rect_or_x = null, y := 0.0, w := 0.0, h := 0.0) -> void:
	if texture_or_attr is _ecImageAttr:
		init_texture_xywh(texture_or_attr.texture, texture_or_attr.x,
				texture_or_attr.y, texture_or_attr.w, texture_or_attr.h)
		_refx = texture_or_attr.refx
		_refy = texture_or_attr.refy
	elif rect_or_x is _ecTextureRect:
		init_texture_xywh(texture_or_attr, rect_or_x.x, rect_or_x.y,
				rect_or_x.w, rect_or_x.h)
		_refx = texture_or_attr.refx
		_refy = texture_or_attr.refy
	else:
		init_texture_xywh(texture_or_attr, rect_or_x, y, w, h)


func init_texture_xywh(texture: _ecTexture, x: float, y: float, w: float, h: float) -> void:
	if texture == null:
		_texture = null
		_texture_w = 1.0
		_texture_h = 1.0
	else:
		_texture = texture
		_texture_w = texture.size_override.x
		_texture_h = texture.size_override.y
	_x = x
	_y = y
	_w = w
	_h = h
	_quad.colors.fill(Color.WHITE)
	_quad.uvs[0] = Vector2(x / _texture_w, y / _texture_h)
	_quad.uvs[1] = Vector2((x + w) / _texture_w, y / _texture_h)
	_quad.uvs[2] = Vector2((x + w) / _texture_w, (y + h) / _texture_h)
	_quad.uvs[3] = Vector2(x / _texture_w, (y + h) / _texture_h)
	_blend_mode = 2
	_flip_x = false
	_flip_y = false
	_flip_ref = false


func init_attr(attr: _ecImageAttr) -> void:
	init_texture_xywh(attr.texture, attr.x, attr.y, attr.w, attr.h)
	_refx = attr.refx
	_refy = attr.refy


func _set_texture(value: _ecTexture) -> void:
	if value != _texture:
		var old_w = _texture_w
		var old_h = _texture_h
		if value == null:
			_texture = null
			_texture_w = 1.0
			_texture_h = 1.0
		else:
			_texture = value
			_texture_w = value.size_override.x
			_texture_h = value.size_override.y
		var v := Vector2(old_w / _texture_w, old_h/ _texture_h)
		_quad.uvs[0] *= v
		_quad.uvs[1] *= v
		_quad.uvs[2] *= v
		_quad.uvs[3] *= v


func set_color(color: Color, vertice: int) -> void:
	if vertice == -1:
		_quad.colors.fill(color)
	else:
		_quad.colors[vertice] = color


func set_alpha(alpha: float, vertice: int) -> void:
	if vertice == -1:
		for i in 4:
			_quad.colors[i].a = alpha
	else:
		_quad.colors[vertice].a = alpha


func _set_flip(flip_x: bool, flip_y: bool, flip_ref: bool) -> void:
	if _flip_ref:
		if _flip_x:
			_refx = _w - _refx
		if _flip_y:
			_refy = _h - _refy
	_flip_ref = flip_ref
	if flip_ref:
		if flip_x:
			_refx = _w - _refx
		if flip_y:
			_refy = _h - _refy
	if flip_x != _flip_x:
		_flip_x = flip_x
		var v0 = _quad.uvs[0]
		_quad.uvs[0] = _quad.uvs[1]
		_quad.uvs[1] = v0
		var v2 = _quad.uvs[2]
		_quad.uvs[2] = _quad.uvs[3]
		_quad.uvs[3] = v2
	if flip_y != _flip_y:
		_flip_y = flip_y
		var v0 = _quad.uvs[0]
		_quad.uvs[0] = _quad.uvs[3]
		_quad.uvs[3] = v0
		var v2 = _quad.uvs[2]
		_quad.uvs[2] = _quad.uvs[1]
		_quad.uvs[1] = v2


func _set_texture_xywh(x: float, y: float, w: float, h: float) -> void:
	var flip_x := _flip_x
	var flip_y := _flip_y
	_flip_x = false
	_flip_y = false
	_quad.uvs[0] = Vector2(x / _texture_w, y / _texture_h)
	_quad.uvs[1] = Vector2((x + w) / _texture_w, y / _texture_h)
	_quad.uvs[2] = Vector2((x + w) / _texture_w, (y + h) / _texture_h)
	_quad.uvs[3] = Vector2(x / _texture_w, (y + h) / _texture_h)
	_set_flip(flip_x, flip_y, _flip_ref)


func _set_texture_rect(rect: _ecTextureRect) -> void:
	_set_texture_xywh(rect.x, rect.y, rect.w, rect.h)
	_refx = rect.refx
	_refy = rect.refy


func render(x:float, y:float) -> void:
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	var graphics := _ecGraphics.instance()
	_quad.points[0] = Vector2(x - _refx, y - _refy)
	_quad.points[1] = Vector2(x - _refx + _w, y - _refy)
	_quad.points[2] = Vector2(x - _refx + _w, y - _refy + _h)
	_quad.points[3] = Vector2(x - _refx, y - _refy + _h)
	graphics.bind_texture(_texture)
	graphics.set_blend_mode(_blend_mode)
	graphics.render_quad(_quad)


func render_xywh(x:float, y:float, w: float, h:float) -> void:
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	var graphics := _ecGraphics.instance()
	_quad.points[0] = Vector2(x - _refx, y - _refy)
	_quad.points[1] = Vector2(x - _refx + w, y - _refy)
	_quad.points[2] = Vector2(x - _refx + w, y - _refy + h)
	_quad.points[3] = Vector2(x - _refx, y - _refy + h)
	graphics.bind_texture(_texture)
	graphics.set_blend_mode(_blend_mode)
	graphics.render_quad(_quad)


func render_ex(x:float, y:float, rotation_rad: float, x_scale: float, y_scale: float) -> void:
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	var graphics := _ecGraphics.instance()
	var w := _w / x_scale
	var h := _h / y_scale
	var refx := _refx / x_scale
	var refy := _refy / y_scale
	var pos := Vector2(x, y)
	var v0 := Vector2( -refx, - refy)
	var v1 := Vector2( -refx + w, - refy)
	var v2 := Vector2( -refx + w, - refy + h)
	var v3 := Vector2( -refx, - refy + h)
	if rotation_rad != 0.0:
		v0 = v0.rotated(rotation_rad)
		v1 = v1.rotated(rotation_rad)
		v2 = v2.rotated(rotation_rad)
		v3 = v3.rotated(rotation_rad)
	_quad.points[0] = pos + v0
	_quad.points[1] = pos + v1
	_quad.points[2] = pos + v2
	_quad.points[3] = pos + v3
	graphics.bind_texture(_texture)
	graphics.set_blend_mode(_blend_mode)
	graphics.render_quad(_quad)


func _render_stretch(x1:float, y1:float, x2: float, y2:float) -> void:
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	var graphics := _ecGraphics.instance()
	_quad.points[0] = Vector2(x1, y1)
	_quad.points[1] = Vector2(x2, y1)
	_quad.points[2] = Vector2(x2, y2)
	_quad.points[3] = Vector2(x1, y2)
	graphics.bind_texture(_texture)
	graphics.set_blend_mode(_blend_mode)
	graphics.render_quad(_quad)


func _render_4v(x0:float, y0:float, x1:float, y1:float, x2: float, y2:float, x3: float, y3:float) -> void:
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	var graphics := _ecGraphics.instance()
	_quad.points[0] = Vector2(x0, y0)
	_quad.points[1] = Vector2(x1, y1)
	_quad.points[2] = Vector2(x2, y2)
	_quad.points[3] = Vector2(x3, y3)
	graphics.bind_texture(_texture)
	graphics.set_blend_mode(_blend_mode)
	graphics.render_quad(_quad)


func render_4vc(x0:float, y0:float, x1:float, y1:float, x2: float, y2:float, x3: float, y3:float, b: int, c: float) -> void:
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	var graphics := _ecGraphics.instance()
	if c < 1.0:
		_quad.points[0] = Vector2(x3, y3) + (Vector2(x0, y0) - Vector2(x3, y3)) * c
		_quad.points[1] = Vector2(x2, y2) + (Vector2(x1, y1) -  Vector2(x2, y2)) * c
		if b == 0:
			_quad.colors.fill(Color.WHITE)
			_quad.colors[2].a = 0.0
			_quad.colors[3].a = 0.0
		elif b == 1:
			_quad.colors[0] = Color.from_rgba8(0x77, 0, 0, 0)
			_quad.colors[1] = Color.from_rgba8(0x77, 0, 0, 0)
			_quad.colors[2] = Color.from_rgba8(0, 0, 0, 0)
			_quad.colors[3] = Color.from_rgba8(0, 0, 0, 0)
	else:
		_quad.points[0] = Vector2(x0, y0)
		_quad.points[1] = Vector2(x1, y1)
		var a := absf(1.0 - 2 * (c - 1.0))
		if b == 0:
			_quad.colors[0] = Color(a, 1.0, 1.0, 1.0)
			_quad.colors[1] = Color(a, 1.0, 1.0, 1.0)
			_quad.colors[2] = Color(0.0, 1.0, 1.0, 1.0)
			_quad.colors[3] = Color(0.0, 1.0, 1.0, 1.0)
		elif b == 1:
			var a8 = (0x77 * a) as int
			_quad.colors[0] = Color.from_rgba8(a8, 0, 0, 0)
			_quad.colors[1] = Color.from_rgba8(a8, 0, 0, 0)
			_quad.colors[2] = Color.from_rgba8(0, 0, 0, 0)
			_quad.colors[3] = Color.from_rgba8(0, 0, 0, 0)
	_quad.points[2] = Vector2(x2, y2)
	_quad.points[3] = Vector2(x3, y3)
	graphics.bind_texture(_texture)
	graphics.set_blend_mode(_blend_mode)
	graphics.render_quad(_quad)
