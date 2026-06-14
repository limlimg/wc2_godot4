extends "res://app/src/main/cpp/gui_element.gd"

## Common component of GUISelBattle and GUISelCountry.

const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")

const _RES_PATH = "res://app/src/main/cpp/scene_system_resource/selbattle_res/"

var _center_pos: Vector2
var _on_animation_finished: Callable
var _move_tween: Tween

@onready var _minimap: Control = $Minimap
@onready var _flag_proto := $Minimap/Prototype/Flag
@onready var _arrow_proto := $Minimap/Prototype/Arrow
@onready var _flags: Node2D = $Minimap/ImageList/Flags
@onready var _age: CenterContainer = $Minimap/ImageList/Age
@onready var _arrows: Node2D = $Minimap/ImageList/Arrows
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	init()


func init() -> void:
	if _ecGraphics.instance().content_scale_size_mode == 3:
		_minimap.scale = Vector2(2.0, 2.0)
		_flag_proto.scale = Vector2(0.5, 0.5)
		_arrow_proto.scale = Vector2(0.5, 0.5)
		_age.scale = Vector2(0.5, 0.5)


func set_image_list(flags:Array[FlagInfo], arrows:Array[FlagInfo], age: String, age_pos: Vector2, center_pos: Vector2) -> void:
	_release_image_list()
	_flags.add_child(_create_element_nodes(flags, "sflag_", _flag_proto))
	_arrows.add_child(_create_element_nodes(arrows, "maparrow_", _arrow_proto))
	$Minimap/ImageList/Age/Label.text = age
	_age.position = age_pos
	_center_pos = center_pos
	if $Minimap/ImageList.modulate.a == 0.0:
		_move_tween = create_tween()
		var dest := _clamp_pos(_center_pos)
		_move_tween.tween_property(_minimap, "position", dest, dest.distance_to(_minimap.position) / 1000.0)
		_move_tween.tween_callback(_on_moving_finished)
	else:
		_minimap.position = _clamp_pos(center_pos)


func _release_image_list() -> void:
	_clear_element_nodes(_flags)
	_clear_element_nodes(_arrows)


func _clear_element_nodes(parent: Node) -> void:
	for i in parent.get_children():
		parent.remove_child(i)
		i.queue_free()


func _create_element_nodes(data: Array[FlagInfo], image_prefix: String, prototype: Sprite2D) -> Node2D:
	var parent := Node2D.new()
	for i in data:
		var image_name := image_prefix + i.name + ".png"
		var image_attr := s_texture_res.get_image(image_name)
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
	center_pos *= _minimap.scale
	var minimap_size := _minimap.size * _minimap.scale
	var result := (center_pos - size / 2.0).max(Vector2.ZERO).min(minimap_size - size)
	if result.x < 0.0:
		result.x *= 0.5
	if result.y < 0.0:
		result.y *= 0.5
	return -result


func change_image_list(flags:Array[FlagInfo], arrows:Array[FlagInfo], age: String, age_pos: Vector2, center_pos: Vector2) -> void:
	if _move_tween != null and _move_tween.is_valid():
		_move_tween.kill()
	if _animation_player.current_animation != &"fade_out":
		_animation_player.stop()
		_animation_player.play(&"fade_out")
	var sig := _animation_player.animation_finished
	if not _on_animation_finished.is_null() and sig.is_connected(_on_animation_finished):
		sig.disconnect(_on_animation_finished)
	_on_animation_finished = func(anim_name: StringName):
		if anim_name == &"fade_out":
			set_image_list(flags, arrows, age, age_pos, center_pos)
	sig.connect(_on_animation_finished, CONNECT_ONE_SHOT)


func _on_moving_finished() -> void:
	_move_tween = null
	_animation_player.play(&"fade_in")


func _on_resized() -> void:
	if is_node_ready():
		if _move_tween != null and _move_tween.is_valid() and _move_tween.is_running():
			_move_tween.kill()
			_on_moving_finished()
		_minimap.position = _clamp_pos(_center_pos)
