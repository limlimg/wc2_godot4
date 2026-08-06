extends GUIElement

## Common component of GUISelBattle and GUISelCountry.

const _CACHE_PATH = "res://scene_system_resource/selbattle_res/"

var _center_pos: Vector2
var _state: int
var _next_flags: Array[FlagInfo]
var _next_arrows: Array[FlagInfo]
var _next_age: String
var _next_age_pos: Vector2
var _next_center_pos: Vector2

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
	if _state != 1:
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
		var image_path := _CACHE_PATH + image_name
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


func change_image_list(flags: Array[FlagInfo], arrows: Array[FlagInfo], age: String, age_pos: Vector2, center_pos: Vector2) -> void:
	_state = 1
	_next_flags = flags
	_next_arrows = arrows
	_next_age = age
	_next_age_pos = age_pos
	_next_center_pos = center_pos


func _on_resized() -> void:
	$Minimap.position = _clamp_pos(-$Minimap.position)


func _process(delta: float) -> void:
	match _state:
		1:
			var a := maxf($Minimap/ImageList.modulate.a - 2.5 * delta, 0.0)
			$Minimap/ImageList.modulate.a = a
			if a <= 0.0:
				$Minimap/ImageList/Arrows.modulate.a = 0.0
				set_image_list(_next_flags, _next_arrows, _next_age, _next_age_pos, _next_center_pos)
				_state = 2
		2:
			var v := 2000.0 if ecGraphics.instance().content_scale_size_mode == 3 else 1000.0
			var d := v * delta
			var dest := _clamp_pos(_center_pos)
			if dest.distance_squared_to($Minimap.position) > d * d:
				$Minimap.position += (dest - $Minimap.position).normalized() * d
			else:
				$Minimap.position = dest
				_state = 3
		3:
			var a := minf($Minimap/ImageList.modulate.a + 2.0 * delta, 1.0)
			$Minimap/ImageList.modulate.a = a
			if a >= 1.0:
				_state = 4
		4:
			var a := minf($Minimap/ImageList/Arrows.modulate.a + 1.5 * delta, 1.0)
			$Minimap/ImageList/Arrows.modulate.a = a
			if a >= 1.0:
				_state = 0
