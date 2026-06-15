extends "res://app/src/main/cpp/gui_element.gd"

## Common component of GUISelBattle and GUISelCountry.

const _ecTextureResAssets = preload("uid://c4lbjg3bsn26n")
const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")

const _RES_PATH = "res://app/src/main/cpp/scene_system_resource/selbattle_res/"

@export
var texture_res: _ecTextureResAssets

var _center_pos: Vector2
var _on_animation_finished: Callable
var _move_tween: Tween

func _ready() -> void:
	init()


func init() -> void:
	if _ecGraphics.instance().content_scale_size_mode == 3:
		$Minimap.scale = Vector2(2.0, 2.0)
		$Minimap/Prototype/Flag.scale = Vector2(0.5, 0.5)
		$Minimap/Prototype/Arrow.scale = Vector2(0.5, 0.5)
		$Minimap/ImageList/Age.scale = Vector2(0.5, 0.5)


func set_image_list(flags:Array[FlagInfo], arrows:Array[FlagInfo], age: String, age_pos: Vector2, center_pos: Vector2) -> void:
	_release_image_list()
	$Minimap/ImageList/Flags.add_child(_create_element_nodes(flags, "sflag_", $Minimap/Prototype/Flag))
	$Minimap/ImageList/Arrows.add_child(_create_element_nodes(arrows, "maparrow_", $Minimap/Prototype/Arrow))
	$Minimap/ImageList/Age/Label.text = age
	$Minimap/ImageList/Age.position = age_pos
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
		parent.remove_child(i)
		i.queue_free()


func _create_element_nodes(data: Array[FlagInfo], image_prefix: String, prototype: Sprite2D) -> Node2D:
	var res := texture_res.get_res()
	var parent := Node2D.new()
	for i in data:
		var image_name := image_prefix + i.name + ".png"
		var image_attr := res.get_image(image_name)
		if image_attr == null:
			continue
		var image_path := _RES_PATH + image_name
		var image: _ecImageTexture
		if not ResourceLoader.has_cached(image_path):
			image = _ecImageTexture.from_ec_image_attr(image_attr)
			image.take_over_path(image_path)
		else:
			image = load(image_path)
		var node: Sprite2D = prototype.duplicate()
		node.texture = image
		node.position = Vector2(i.x, i.y)
		node.rotation = i.rot
		node.scale *= i.scale
		parent.add_child(node)
	return parent


func _clamp_pos(center_pos: Vector2) -> Vector2:
	center_pos *= $Minimap.scale
	var minimap_size: Vector2 = $Minimap.size * $Minimap.scale
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
	var sig: Signal = $AnimationPlayer.animation_finished
	if not _on_animation_finished.is_null() and sig.is_connected(_on_animation_finished):
		sig.disconnect(_on_animation_finished)
	_on_animation_finished = func(anim_name: StringName):
		if anim_name == &"fade_out":
			set_image_list(flags, arrows, age, age_pos, center_pos)
	sig.connect(_on_animation_finished, CONNECT_ONE_SHOT)


func _on_moving_finished() -> void:
	_move_tween = null
	$AnimationPlayer.play(&"fade_in")


func _on_resized() -> void:
	if _move_tween != null and _move_tween.is_valid() and _move_tween.is_running():
		_move_tween.kill()
		_on_moving_finished()
	$Minimap.position = _clamp_pos(_center_pos)
