class_name CCamera
extends Control

const _MOVE_SPEED = [0.012, 0.015, 0.02, 0.026, 0.034]

var scene_rect: Rect2:
	set = set_scene_rect

var camera_position: Vector2:
	get():
		return $Camera2D.position
	set(value):
		$Camera2D.position = value


var camera_zoom: Vector2:
	get():
		return $Camera2D.zoom
	set(value):
		$Camera2D.zoom = value


var _move_timer: int
var is_moving: bool
var _target_pos: Vector2
var _target_zoom := 1.0

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		$Camera2D.enabled = is_visible_in_tree()


func init(init_scene_rect: Rect2) -> void:
	set_scene_rect(init_scene_rect)
	$Camera2D.zoom = Vector2.ONE


func set_scene_rect(value: Rect2) -> void:
	if value != scene_rect:
		scene_rect = value


func set_pos(x: float, y: float, exclude_box: bool) -> void:
	_target_pos = Vector2(x, y)
	$Camera2D.position = _clamp_pos(x, y, exclude_box)


func _clamp_pos(x: float, y: float, exclude_box: bool) -> Vector2:
	var bound := scene_rect
	if not exclude_box:
		bound.position -= Vector2(82.0, 82.0)
		bound.size += Vector2(164.0, 164.0)
	var view_size = size / $Camera2D.zoom
	if view_size.x < bound.size.x:
		bound.position.x += view_size.x / 2
		bound.size.x -= view_size.x
	else:
		bound.position.x += bound.size.x / 2
		bound.size.x = 0.0
	if view_size.y < bound.size.y:
		bound.position.y += view_size.y / 2
		bound.size.y -= view_size.y
	else:
		bound.position.y += bound.size.y / 2
		bound.size.y = 0.0
	x = clampf(x, bound.position.x, bound.end.x)
	y = clampf(y, bound.position.y, bound.end.y)
	return Vector2(x, y)


func set_pos_and_scale(x: float, y: float, zoom: float) -> void:
	_target_pos = Vector2(x, y)
	_target_zoom = zoom
	var min_scale := 0.5 if EC2dAppDelegate.g_content_scale_factor == 2.0 else 0.68
	if min_scale < size.x / scene_rect.size.x:
		min_scale = size.x / scene_rect.size.x
	if min_scale < size.y / scene_rect.size.y:
		min_scale = size.y / scene_rect.size.y
	zoom = clampf(zoom, min_scale, maxf(min_scale, 1.0))
	$Camera2D.zoom = Vector2(zoom, zoom)
	$Camera2D.position = _clamp_pos(x, y, true)


func move(x: float, y: float, exclude_box: bool) -> bool:
	var pos = $Camera2D.position
	_target_pos = pos + Vector2(x, y) / $Camera2D.zoom
	$Camera2D.position = _clamp_pos(_target_pos.x, _target_pos.y, exclude_box)
	return $Camera2D.position.x == pos.x or $Camera2D.position.y == pos.y


func set_auto_fix_pos(value: bool) -> void:
	_target_pos.x = clampf(_target_pos.x, scene_rect.position.x, scene_rect.end.x)
	_target_pos.y = clampf(_target_pos.y, scene_rect.position.y, scene_rect.end.y)
	if value:
		if not Rect2(-0.1, -0.1, 0.2, 0.2).has_point(_clamp_pos(_target_pos.x, _target_pos.y, true) - $Camera2D.position):
			_move_timer = 10
			is_moving = true
	else:
		is_moving = false


func move_to(x: float, y: float, _exclude_box: bool) -> void:
	_target_pos = Vector2(x, y)
	var speed = _MOVE_SPEED[g_GameSettings.speed - 1]
	_move_timer = ceili(1.0 / speed)
	is_moving = true


func update(_delta: float) -> void:
	if not is_moving:
		return
	_move_timer -= 1
	if _move_timer > 1:
		$Camera2D.position = $Camera2D.position.lerp(_clamp_pos(_target_pos.x, _target_pos.y, true), 1.0 / _move_timer)
	else:
		$Camera2D.position = _clamp_pos(_target_pos.x, _target_pos.y, true)
		is_moving = false


func is_rect_in_camera(rect: Rect2) -> bool:
	var visible_region: Rect2
	var view_size = size / camera_zoom
	visible_region.position = camera_position - view_size / 2
	visible_region.size = view_size
	return visible_region.intersects(rect)


func is_rect_in_visible_region(rect: Rect2) -> bool:
	var visible_region: Rect2
	var view_size_x := size.x / camera_zoom.x
	if ecGraphics.instance().content_scale_size_mode == 3:
		visible_region.position = $Camera2D.position - Vector2(view_size_x / 2, 346.0 / camera_zoom.y)
		visible_region.size = Vector2(view_size_x, 666.0 / camera_zoom.y)
	else:
		visible_region.position = $Camera2D.position - Vector2(view_size_x / 2, 130.0 / camera_zoom.y)
		visible_region.size = Vector2(view_size_x, 243.0 / camera_zoom.y)
	return visible_region.encloses(rect)


func _on_resized() -> void:
	set_pos_and_scale(_target_pos.x, _target_pos.y, _target_zoom)
