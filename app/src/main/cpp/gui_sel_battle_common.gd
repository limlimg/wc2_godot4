extends "res://app/src/main/cpp/gui_element.gd"

## Common component of GUISelBattle and GUISelCountry.

const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")

const _RES_PATH = "res://app/src/main/cpp/scene_system_resource/selbattle_res/"

var _center_pos: Vector2
var _cur_tween_state := 0
var _cur_tween: Tween

@onready var _minimap: Control = $Minimap
@onready var _flag_proto := $Minimap/Prototype/Flag
@onready var _arrow_proto := $Minimap/Prototype/Arrow
@onready var _image_list: Node2D = $Minimap/ImageList
@onready var _flags: Node2D = $Minimap/ImageList/Flags
@onready var _age: CenterContainer = $Minimap/ImageList/Age
@onready var _arrows: Node2D = $Minimap/ImageList/Arrows

signal ok_pressed
signal back_pressed

func _ready() -> void:
	init()


func init() -> void:
	if _ecGraphics.instance().content_scale_size_mode == 3:
		_minimap.scale = Vector2(2.0, 2.0)
		_flag_proto.scale = Vector2(0.5, 0.5)
		_arrow_proto.scale = Vector2(0.5, 0.5)
		_age.scale = Vector2(0.5, 0.5)


func release_image_list() -> void:
	_clear_element_nodes(_flags)
	_clear_element_nodes(_arrows)


func _clear_element_nodes(parent: Node) -> void:
	for i in parent.get_children():
		parent.remove_child(i)
		i.queue_free()


func set_image_list(flags:Array[FlagInfo], arrows:Array[FlagInfo], age: String, age_pos: Vector2, center_pos: Vector2) -> void:
	_flags.add_child(_create_element_nodes(flags, "sflag_", _flag_proto))
	_arrows.add_child(_create_element_nodes(arrows, "maparrow_", _arrow_proto))
	$Minimap/ImageList/Age/Label.text = age
	_age.position = age_pos
	_center_pos = center_pos
	if _cur_tween_state == 1:
		_cur_tween = create_tween()
		var dest := _clamp_pos(_center_pos)
		_cur_tween.tween_property(_minimap, "position", dest, dest.distance_to(_minimap.position) / 1000.0)
		_cur_tween_state = 2
		_cur_tween.tween_callback(_tween_fade_in_image)
	else:
		_minimap.position = _clamp_pos(center_pos)


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
	if _cur_tween_state != 1 and _cur_tween != null and _cur_tween.is_valid():
		_cur_tween.kill()
	_image_list.modulate.a = 1.0
	_arrows.modulate.a = 1.0
	_cur_tween_state = 1
	_cur_tween = create_tween()
	_cur_tween.tween_property(_image_list, "modulate", Color(_image_list.modulate, 0.0), 0.4)
	_cur_tween.tween_callback(func ():
		_arrows.modulate.a = 0.0
		set_image_list(flags, arrows, age, age_pos, center_pos)
		)


func _tween_fade_in_image() -> void:
	_cur_tween_state = 3
	_cur_tween = create_tween()
	_cur_tween.tween_property(_image_list, "modulate", Color(_image_list.modulate, 1.0), 0.5)
	_cur_tween.tween_callback(func ():
		_cur_tween_state = 4
		)
	_cur_tween.tween_property(_arrows, "modulate", Color(_arrows.modulate, 1.0), 1.0/1.5)
	_cur_tween.tween_callback(func ():
		_cur_tween_state = 0
		)


func _on_resized() -> void:
	if is_node_ready():
		if _cur_tween_state == 2:
			_cur_tween.kill()
			_tween_fade_in_image()
		_minimap.position = _clamp_pos(_center_pos)


func _on_button_ok_pressed() -> void:
	ok_pressed.emit()


func _on_button_back_pressed() -> void:
	back_pressed.emit()
