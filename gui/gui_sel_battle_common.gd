extends GUIElement

## Common component of GUISelBattle and GUISelCountry.

const _RES_PATH = "res://scene_system_resource/selbattle_res/"

@export
var texture_res: ecTextureRes

var _center_pos: Vector2
var _change_order := 0
var _move_tween: Tween

func set_image_list(flags:Array[FlagInfo], arrows:Array[FlagInfo], age: String, age_pos: Vector2, center_pos: Vector2) -> void:
	_release_image_list()
	$Minimap/ImageList/Flags.add_child(_create_element_nodes(flags, "sflag_", $Minimap/Prototype/Flag))
	$Minimap/ImageList/Arrows.add_child(_create_element_nodes(arrows, "maparrow_", $Minimap/Prototype/Arrow))
	$Minimap/ImageList/Num6/Age.text = age
	if ecGraphics.instance().content_scale_size_mode == 3:
		age_pos *= 2
		center_pos *= 2
	$Minimap/ImageList/Num6.position = age_pos
	_center_pos = center_pos
	if $Minimap/ImageList.modulate.a == 0.0:
		_move_tween = create_tween()
		var dest := _clamp_pos(_center_pos)
		_move_tween.tween_property($Minimap, "position", dest, dest.distance_to($Minimap.position) / 1000.0)
		_move_tween.tween_callback(_on_moving_finished)
	else:
		$Minimap.position = _clamp_pos(center_pos)


func _release_image_list() -> void:
	_clear_element_nodes($Minimap/ImageList/Flags)
	_clear_element_nodes($Minimap/ImageList/Arrows)


func _clear_element_nodes(parent: Node) -> void:
	for i in parent.get_children():
		i.queue_free()


func _create_element_nodes(data: Array[FlagInfo], image_prefix: String, prototype: Sprite2D) -> Node2D:
	var res := texture_res
	var parent := Node2D.new()
	for i in data:
		var image_name := image_prefix + i.name + ".png"
		var image_attr := res.get_image(image_name)
		if image_attr == null:
			continue
		var image_path := _RES_PATH + image_name
		var image: Texture2D
		if not ResourceLoader.has_cached(image_path):
			image = image_attr
			image.take_over_path(image_path)
		else:
			image = ResourceLoader.get_cached_ref(image_path)
		var node: Sprite2D = prototype.duplicate()
		node.texture = image
		if ecGraphics.instance().content_scale_size_mode == 3:
			node.position = Vector2(i.x, i.y) * 2
		else:
			node.position = Vector2(i.x, i.y)
		node.rotation = i.rot
		node.scale *= i.scale
		parent.add_child(node)
	return parent


func _clamp_pos(center_pos: Vector2) -> Vector2:
	var minimap_size: Vector2 = $Minimap/Background.size
	var result := (center_pos - size / 2.0).max(Vector2.ZERO).min(minimap_size - size)
	if result.x < 0.0:
		result.x *= 0.5
	if result.y < 0.0:
		result.y *= 0.5
	return -result


func change_image_list(flags:Array[FlagInfo], arrows:Array[FlagInfo], age: String, age_pos: Vector2, center_pos: Vector2) -> void:
	if _move_tween != null and _move_tween.is_valid():
		_move_tween.kill()
	if $AnimationPlayer.current_animation != &"fade_out":
		$AnimationPlayer.stop()
		$AnimationPlayer.play(&"fade_out")
	_change_order += 1
	var waiting_change_order := _change_order
	var anim_name: StringName = await $AnimationPlayer.animation_finished
	if anim_name == &"fade_out" and _change_order == waiting_change_order:
		set_image_list(flags, arrows, age, age_pos, center_pos)


func _on_moving_finished() -> void:
	_move_tween = null
	$AnimationPlayer.play(&"fade_in")


func _on_resized() -> void:
	if _move_tween != null and _move_tween.is_valid() and _move_tween.is_running():
		_move_tween.kill()
		_on_moving_finished()
	$Minimap.position = _clamp_pos(_center_pos)
