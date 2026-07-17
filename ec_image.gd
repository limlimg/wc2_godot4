@tool
extends Node2D

@export
var texture: Texture2D:
	set = set_texture


@export
var colors: PackedColorArray = [Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE]:
	get():
		colors.resize(4)
		return colors
	set(value):
		if value != colors:
			colors = value.duplicate()
			colors.resize(4)
			queue_redraw()


@export
var flip_h: bool:
	set(value):
		if value != flip_h:
			flip_h = value
			if flip_relative_to_origin:
				_point_rect = _flip_points(_point_rect, true, false, true)
			_uv_rect = _flip_points(_uv_rect, true, false, false)
			queue_redraw()


@export
var flip_v: bool:
	set(value):
		if value != flip_v:
			flip_v = value
			if flip_relative_to_origin:
				_point_rect = _flip_points(_point_rect, false, true, true)
			_uv_rect = _flip_points(_uv_rect, false, true, false)
			queue_redraw()


@export
var flip_relative_to_origin: bool:
	set(value):
		if value != flip_relative_to_origin:
			flip_relative_to_origin = value
			if flip_h:
				_point_rect = _flip_points(_point_rect, true, false, true)
			if flip_v:
				_point_rect = _flip_points(_point_rect, false, true, true)
			queue_redraw()


@export
var _point_rect: Rect2
@export
var _uv_rect: Rect2
var _quad := ecQuad.new()

func init():
	var x: float
	var y: float
	var w: float
	var h: float
	var refx: float
	var refy: float
	var texture_w: float
	var texture_h: float
	if texture is ecImageAttr:
		x = texture.region.position.x
		y = texture.region.position.y
		w = texture.region.size.x
		h = texture.region.size.y
		refx = texture.origin.x
		refy = texture.origin.y
		if texture.texture != null:
			texture_w = texture.texture.get_width()
			texture_h = texture.texture.get_height()
		else:
			texture_w = 1.0
			texture_h = 1.0
	else:
		x = 0.0
		y = 0.0
		if texture != null:
			w = texture.get_width()
			texture_w = w
			h = texture.get_height()
			texture_h = h
		else:
			w = 1.0
			h = 1.0
			texture_w = 1.0
			texture_h = 1.0
		refx = 0.0
		refy = 0.0
	if texture != null:
		_point_rect = Rect2(-refx, -refy, w, h)
		_uv_rect = Rect2(x / texture_w, y / texture_h, w / texture_w, h / texture_h)
		if flip_h:
			if flip_relative_to_origin:
				_flip_points(_point_rect, true, false, true)
			_flip_points(_uv_rect, true, false, false)
		if flip_v:
			if flip_relative_to_origin:
				_flip_points(_point_rect, false, true, true)
			_flip_points(_uv_rect, false, true, false)
	else:
		_point_rect.size = Vector2.ZERO
	queue_redraw()


func set_texture(value: Texture2D) -> void:
	if value != texture:
		if texture != null:
			texture.changed.disconnect(init)
		texture = value
		init()
		if value != null:
			value.changed.connect(init)


func set_color(color: Color, vertice: int) -> void:
	if vertice == -1:
		colors.fill(color)
	else:
		colors[vertice] = color


func set_alpha(alpha: float, vertice: int) -> void:
	if vertice == -1:
		for i in 4:
			colors[i].a = alpha
	else:
		colors[vertice].a = alpha


func set_flip(flip_x: bool, flip_y: bool, flip_ref: bool) -> void:
	flip_h = flip_x
	flip_v = flip_y
	flip_relative_to_origin = flip_ref


func _flip_points(points: Rect2, flip_x: bool, flip_y: bool, flip_ref: bool) -> Rect2:
	if flip_x:
		var x := points.position.x
		points.position.x = -points.end.x if flip_ref else points.end.x
		points.end.x = -x if flip_ref else x
	if flip_y:
		var y := points.position.y
		points.position.y = -points.end.y if flip_ref else points.end.y
		points.end.y = -y if flip_ref else y
	return points


func _set_texture_xywh(x: float, y: float, w: float, h: float) -> void:
	var new_attr := ecImageAttr.new()
	new_attr.texture = texture.texture if texture is ecImageAttr else texture
	new_attr.region.position.x = x
	new_attr.region.position.y = y
	new_attr.region.size.x = w
	new_attr.region.size.y = h
	texture = new_attr


func _set_texture_rect(rect: ecTextureRect) -> void:
	var new_attr := ecImageAttr.new()
	new_attr.texture = texture.texture if texture is ecImageAttr else texture
	new_attr.region = rect.region
	new_attr.origin = rect.origin
	texture = new_attr


func _draw() -> void:
	ecGraphics.instance().render_begin(self)
	render(0.0, 0.0)
	ecGraphics.instance().render_end()


func render(x:float, y:float) -> void:
	if texture == null:
		return
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	_quad.points[0] = _point_rect.position + Vector2(x, y)
	_quad.points[1] = Vector2(_point_rect.end.x, _point_rect.position.y) + Vector2(x, y)
	_quad.points[2] = _point_rect.end + Vector2(x, y)
	_quad.points[3] = Vector2(_point_rect.position.x, _point_rect.end.y) + Vector2(x, y)
	_quad.colors[0] = colors[0]
	_quad.colors[1] = colors[1]
	_quad.colors[2] = colors[2]
	_quad.colors[3] = colors[3]
	_quad.uvs[0] = _uv_rect.position
	_quad.uvs[1] = Vector2(_uv_rect.end.x, _uv_rect.position.y)
	_quad.uvs[2] = _uv_rect.end
	_quad.uvs[3] = Vector2(_uv_rect.position.x, _uv_rect.end.y)
	var graphics := ecGraphics.instance()
	graphics.bind_texture(texture.texture if texture is ecImageAttr else texture)
	graphics.render_quad(_quad)


func render_rect(x:float, y:float, w: float, h:float) -> void:
	if texture == null:
		return
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	_quad.points[0] = _point_rect.position + Vector2(x, y)
	_quad.points[1] = _point_rect.position + Vector2(x + w, y)
	_quad.points[2] = _point_rect.position + Vector2(x + w, y + h)
	_quad.points[3] = _point_rect.position + Vector2(x, y + h)
	_quad.colors[0] = colors[0]
	_quad.colors[1] = colors[1]
	_quad.colors[2] = colors[2]
	_quad.colors[3] = colors[3]
	_quad.uvs[0] = _uv_rect.position
	_quad.uvs[1] = Vector2(_uv_rect.end.x, _uv_rect.position.y)
	_quad.uvs[2] = _uv_rect.end
	_quad.uvs[3] = Vector2(_uv_rect.position.x, _uv_rect.end.y)
	var graphics := ecGraphics.instance()
	graphics.bind_texture(texture.texture if texture is ecImageAttr else texture)
	graphics.render_quad(_quad)


func render_tile(x:float, y:float, w: float, h:float) -> void:
	if texture == null:
		return
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	_quad.points[0] = _point_rect.position + Vector2(x, y)
	_quad.points[1] = _point_rect.position + Vector2(x + w, y)
	_quad.points[2] = _point_rect.position + Vector2(x + w, y + h)
	_quad.points[3] = _point_rect.position + Vector2(x, y + h)
	_quad.colors[0] = colors[0]
	_quad.colors[1] = colors[1]
	_quad.colors[2] = colors[2]
	_quad.colors[3] = colors[3]
	_quad.uvs[0] = _uv_rect.position
	_quad.uvs[1] = Vector2(_uv_rect.end.x, _uv_rect.position.y)
	_quad.uvs[2] = _uv_rect.end
	_quad.uvs[3] = Vector2(_uv_rect.position.x, _uv_rect.end.y)
	var graphics := ecGraphics.instance()
	graphics.bind_texture(texture.texture if texture is ecImageAttr else texture)
	graphics.render_quad(_quad)


func render_ex(x:float, y:float, rotation_rad: float, x_scale: float, y_scale: float) -> void:
	if texture == null:
		return
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	if y_scale == 0.0:
		y_scale = x_scale
	var ex_transform := Transform2D.IDENTITY.scaled(Vector2(x_scale, y_scale)).rotated(rotation_rad).translated(Vector2(x, y))
	_quad.points[0] = ex_transform * _point_rect.position
	_quad.points[1] = ex_transform * Vector2(_point_rect.end.x, _point_rect.position.y)
	_quad.points[2] = ex_transform * _point_rect.end
	_quad.points[3] = ex_transform * Vector2(_point_rect.position.x, _point_rect.end.y)
	_quad.colors[0] = colors[0]
	_quad.colors[1] = colors[1]
	_quad.colors[2] = colors[2]
	_quad.colors[3] = colors[3]
	_quad.uvs[0] = _uv_rect.position
	_quad.uvs[1] = Vector2(_uv_rect.end.x, _uv_rect.position.y)
	_quad.uvs[2] = _uv_rect.end
	_quad.uvs[3] = Vector2(_uv_rect.position.x, _uv_rect.end.y)
	var graphics := ecGraphics.instance()
	graphics.bind_texture(texture.texture if texture is ecImageAttr else texture)
	graphics.render_quad(_quad)


func render_stretch(x1:float, y1:float, x2: float, y2:float) -> void:
	if texture == null:
		return
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	_quad.points[0] = Vector2(x1, y1)
	_quad.points[1] = Vector2(x2, y1)
	_quad.points[2] = Vector2(x2, y2)
	_quad.points[3] = Vector2(x1, y2)
	_quad.colors[0] = colors[0]
	_quad.colors[1] = colors[1]
	_quad.colors[2] = colors[2]
	_quad.colors[3] = colors[3]
	_quad.uvs[0] = _uv_rect.position
	_quad.uvs[1] = Vector2(_uv_rect.end.x, _uv_rect.position.y)
	_quad.uvs[2] = _uv_rect.end
	_quad.uvs[3] = Vector2(_uv_rect.position.x, _uv_rect.end.y)
	var graphics := ecGraphics.instance()
	graphics.bind_texture(texture.texture if texture is ecImageAttr else texture)
	graphics.render_quad(_quad)


func render_4v(x0:float, y0:float, x1:float, y1:float, x2: float, y2:float, x3: float, y3:float) -> void:
	if texture == null:
		return
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	_quad.points[0] = Vector2(x0, y0)
	_quad.points[1] = Vector2(x1, y1)
	_quad.points[2] = Vector2(x2, y2)
	_quad.points[3] = Vector2(x3, y3)
	_quad.colors[0] = colors[0]
	_quad.colors[1] = colors[1]
	_quad.colors[2] = colors[2]
	_quad.colors[3] = colors[3]
	_quad.uvs[0] = _uv_rect.position
	_quad.uvs[1] = Vector2(_uv_rect.end.x, _uv_rect.position.y)
	_quad.uvs[2] = _uv_rect.end
	_quad.uvs[3] = Vector2(_uv_rect.position.x, _uv_rect.end.y)
	var graphics := ecGraphics.instance()
	graphics.bind_texture(texture.texture if texture is ecImageAttr else texture)
	graphics.render_quad(_quad)


func render_4vc(x0:float, y0:float, x1:float, y1:float, x2: float, y2:float, x3: float, y3:float, b: int, c: float) -> void:
	if texture == null:
		return
	# g_content_scale_factor is stored to window.content_scale_factor so the values in this function should NOT care about it
	if c < 1.0:
		_quad.points[0] = Vector2(x3, y3) + (Vector2(x0, y0) - Vector2(x3, y3)) * c
		_quad.points[1] = Vector2(x2, y2) + (Vector2(x1, y1) -  Vector2(x2, y2)) * c
		if b == 0:
			_quad.colors.fill(Color.WHITE)
			_quad.colors[2].a = 0.0
			_quad.colors[3].a = 0.0
		elif b == 1:
			_quad.colors[0] = Color.from_rgba8(0, 0, 0, 0x77)
			_quad.colors[1] = Color.from_rgba8(0, 0, 0, 0x77)
			_quad.colors[2] = Color.from_rgba8(0, 0, 0, 0)
			_quad.colors[3] = Color.from_rgba8(0, 0, 0, 0)
	else:
		_quad.points[0] = Vector2(x0, y0)
		_quad.points[1] = Vector2(x1, y1)
		var a := absf(1.0 - 2 * (c - 1.0))
		if b == 0:
			_quad.colors[0] = Color(1.0, 1.0, 1.0, a)
			_quad.colors[1] = Color(1.0, 1.0, 1.0, a)
			_quad.colors[2] = Color(1.0, 1.0, 1.0, 0.0)
			_quad.colors[3] = Color(1.0, 1.0, 1.0, 0.0)
		elif b == 1:
			var a8 = (0x77 * a) as int
			_quad.colors[0] = Color.from_rgba8(0, 0, 0, a8)
			_quad.colors[1] = Color.from_rgba8(0, 0, 0, a8)
			_quad.colors[2] = Color.from_rgba8(0, 0, 0, 0)
			_quad.colors[3] = Color.from_rgba8(0, 0, 0, 0)
	_quad.points[2] = Vector2(x2, y2)
	_quad.points[3] = Vector2(x3, y3)
	_quad.uvs[0] = _uv_rect.position
	_quad.uvs[1] = Vector2(_uv_rect.end.x, _uv_rect.position.y)
	_quad.uvs[2] = _uv_rect.end
	_quad.uvs[3] = Vector2(_uv_rect.position.x, _uv_rect.end.y)
	var graphics := ecGraphics.instance()
	graphics.bind_texture(texture.texture if texture is ecImageAttr else texture)
	graphics.render_quad(_quad)
