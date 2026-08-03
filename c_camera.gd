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


var _target_pos: Vector2
var _target_zoom := 1.0
var _move_tween: Tween

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
	zoom = maxf(zoom, min_scale)
	$Camera2D.zoom = Vector2(zoom, zoom)
	$Camera2D.position = _clamp_pos(x, y, true)


func move(x: float, y: float, exclude_box: bool) -> void:
	var pos = $Camera2D.position
	pos += Vector2(x, y) / $Camera2D.zoom
	_target_pos = pos
	$Camera2D.position = _clamp_pos(pos.x, pos.y, exclude_box)


func set_auto_fix_pos(value: bool) -> void:
	_target_pos.x = clampf(_target_pos.x, scene_rect.position.x, scene_rect.end.x)
	_target_pos.y = clampf(_target_pos.y, scene_rect.position.y, scene_rect.end.y)
	if value:
		if _move_tween != null:
			_move_tween.kill()
		_move_tween = create_tween()
		var pos = $Camera2D.position
		var target := _clamp_pos(pos.x, pos.y, true)
		_move_tween.tween_property($Camera2D, ^"position", target, 1.0 / 0.1 / 60.0)
	else:
		if _move_tween != null:
			_move_tween.kill()
			_move_tween = null


func move_to(x: float, y: float, exclude_box: bool) -> void:
	_target_pos = Vector2(x, y)
	if _move_tween != null:
		_move_tween.kill()
	_move_tween = create_tween()
	var speed = _MOVE_SPEED[g_GameSettings.speed - 1]
	var target = _clamp_pos(x, y, exclude_box)
	_move_tween.tween_property($Camera2D, ^"position", target, 1.0 / speed / 60.0)


func is_rect_in_camera(rect: Rect2) -> bool:
	return scene_rect.intersects(rect)


func is_rect_in_visible_region(rect: Rect2) -> bool:
	var visible_region: Rect2
	var view_size = size / $Camera2D.zoom
	visible_region.position = $Camera2D.position - view_size / 2
	visible_region.size = view_size
	return visible_region.intersects(rect)


func is_moving() -> bool:
	return _move_tween != null and _move_tween.is_running()


func _on_resized() -> void:
	set_pos_and_scale(_target_pos.x, _target_pos.y, _target_zoom)
