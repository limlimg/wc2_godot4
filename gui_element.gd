class_name GUIElement
extends Control

## In the original game code, GUIElements are, as its name suggests, components
## of the graphical user interface. They are organized in a tree structure, with
## GUIManager::Instance() always being the root. They communicate with each
## other via OnEvent method. Inputs trigger this method and spread to the
## children of an element if not handled by its OnEvent method. Elements can
## also create events which spread along its ancestors. This kind of events
## usually reach the GUIManager which then send them to the current active state.
## OnUpdate method updates the element and OnRender renders the element.
##
## In this projects, GUIElements inherits Control node class. Inputs are handled
## by children nodes or _input callback if necessary. Up-spreading events are
## replaced by signals. Time-based changes are handled by Tween or _process
## callback if necessary. Rendering is implemented with children nodes or _draw
## callback if necessary (remember to call queue_redraw in _process if using
## this). Some of the original methods collide with the built-in methods of
## Control and are therefore not coded in this file.
## 
## The original SetVisible method is unused and not implemented due to name
## conflict with engine method.

static var _next_handle: int
static var s_texture_res := ecTextureRes.new()

@export
var rect: GUIRect:
	set(value):
		if value != rect:
			if rect != null:
				rect.changed.disconnect(init)
			rect = value
			init()
			if value != null:
				value.changed.connect(init)


@export
var rect_ipad: GUIRect:
	set(value):
		if value != rect_ipad:
			if rect_ipad != null:
				rect_ipad.changed.disconnect(init)
			rect_ipad = value
			init()
			if value != null:
				value.changed.connect(init)


@export
var rect_640h: GUIRect:
	set(value):
		if value != rect_640h:
			if rect_640h != null:
				rect_640h.changed.disconnect(init)
			rect_640h = value
			init()
			if value != null:
				value.changed.connect(init)


@export
var rect_568h: GUIRect:
	set(value):
		if value != rect_568h:
			if rect_568h != null:
				rect_568h.changed.disconnect(init)
			rect_568h = value
			init()
			if value != null:
				value.changed.connect(init)

@export
var texture_res: ecTextureRes

var _handle: int

func _ready() -> void:
	_next_handle += 1
	_handle = _next_handle
	init()


func init() -> void:
	if not is_node_ready():
		return
	var selected_rect := _get_selected_rect()
	if selected_rect != null:
		offset_left = selected_rect.rect.position.x
		offset_top = selected_rect.rect.position.y
		offset_right = selected_rect.rect.position.x
		offset_bottom = selected_rect.rect.position.y
		scale = selected_rect.scale
	update_minimum_size()


func _get_selected_rect() -> GUIRect:
	var selected_rect: GUIRect
	var graphics := ecGraphics.instance()
	if graphics.content_scale_size_mode == 3:
		selected_rect = rect_ipad
	elif graphics.orientated_content_scale_width > 568.0:
		selected_rect = rect_640h
	elif graphics.orientated_content_scale_width > 480.0:
		selected_rect = rect_568h
	if selected_rect == null:
		selected_rect = rect
	return selected_rect


func _get_minimum_size() -> Vector2:
	var selected_rect := _get_selected_rect()
	if selected_rect != null:
		return selected_rect.rect.size
	else:
		return Vector2.ZERO


func free_child(child: Node) -> void:
	if child != null:
		remove_child(child)
		child.free()


func free_all_child() -> void:
	for i in get_children():
		free_child(i)


func get_pos() -> Vector2:
	return position


func set_pos(x: float, y: float) -> void:
	position = Vector2(x, y)


func _move(x: float, y: float) -> void:
	position += Vector2(x, y)


func center() -> void:
	var c: Vector2
	var parent := get_parent_control()
	if parent != null:
		c = parent.size / 2
	else:
		var graphics := ecGraphics.instance()
		c = Vector2(graphics.orientated_content_scale_width, graphics.orientated_content_scale_height)
	position = c - size / 2


func get_abs_rect() -> Rect2:
	return get_global_rect()


func check_in_rect(x: float, y: float, in_rect := get_abs_rect()) -> bool:
	return in_rect.has_point(Vector2(x, y))


func set_enable(value: bool) -> void:
	if "enable" in self:
		self.enable = value


func _find_by_handle(handle: int) -> GUIElement:
	if _handle == handle:
		return self
	for child in get_children():
		if child is GUIElement:
			var result = child._find_by_handle(handle)
			if result != null:
				return result
	return null
