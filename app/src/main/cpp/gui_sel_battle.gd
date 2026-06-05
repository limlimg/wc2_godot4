extends "res://app/src/main/cpp/gui_element.gd"

const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")
const _ecImage = preload("res://app/src/main/cpp/ec_image.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _GUIBattleList = preload("res://app/src/main/cpp/gui_battle_list.gd")
const _CObjectDef = preload("res://app/src/main/cpp/c_object_def.gd")
const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")

const _RES_PATH = "res://app/src/main/cpp/scene_system_resource/selbattle_res/"
const _CAMPAIGN_LOGO = [
	_RES_PATH + "logo_axis.png.tres",
	_RES_PATH + "logo_allies.png.tres",
	_RES_PATH + "logo_wto.png.tres",
	_RES_PATH + "logo_nato.png.tres"
]

@export
var game_mode: int:
	set(value):
		game_mode = value
		$ButtonInfo.visible = (value != 0)


@export
var campaign: int:
	get():
		return _battle_list.campaign
	set(value):
		if value != campaign:
			_battle_list.campaign = value
			if is_node_ready():
				init()


var _battle := -1
var _center_pos: Vector2
var _cur_tween_state := 0
var _cur_tween: Tween
@onready var _battle_list := $GUIBattleList/GUIBattleList
@onready var _flag_proto := $Minimap/ImageList/Flags/Flag
@onready var _arrow_proto := $Minimap/ImageList/Arrows/Arrow
@onready var _minimap: Control = $Minimap
@onready var _gui_battle_intro: Control = $GUIBattleIntro
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
	var logo: Texture2D = null
	if campaign < _CAMPAIGN_LOGO.size():
		logo = load(_CAMPAIGN_LOGO[campaign]) as Texture2D
	$Logo/TextureRect.texture = logo
	s_texture_res = load("res://app/src/main/cpp/scene_system_resource/selbattle_res/texture_res.tres").get_res()
	if game_mode != 4 and g_Commander.get_num_played_battles(campaign) < _native.get_num_battles(campaign):
		_battle_list.select_last_unlocked()
	else:
		_battle_list.set_select(0)


func _on_gui_battle_list_battle_selected(battle: int) -> void:
	if _battle < 0:
		_sel_battle(campaign, battle)
		_minimap.position = _clamp_pos(_center_pos)
	else:
		if _cur_tween_state != 1 and _cur_tween != null and _cur_tween.is_valid():
			_cur_tween.kill()
		_image_list.modulate.a = 1.0
		_arrows.modulate.a = 1.0
		_cur_tween_state = 1
		_cur_tween = create_tween()
		_cur_tween.tween_property(_image_list, "modulate", Color(_image_list.modulate, 0.0), 0.4)
		_cur_tween.tween_callback(func ():
			_arrows.modulate.a = 0.0
			_sel_battle(campaign, _battle)
			_cur_tween = create_tween()
			var dest := _clamp_pos(_center_pos)
			_cur_tween.tween_property(_minimap, "position", dest, dest.distance_to(_minimap.position) / 1000.0)
			_cur_tween_state = 2
			_cur_tween.tween_callback(_tween_fade_in_image)
			)
	_battle = battle


func _sel_battle(sel_campaign: int, battle: int) -> void:
	_release_image_list()
	_load_image_list(sel_campaign, battle)


func _release_image_list() -> void:
	_clear_element_nodes(_flags, _flag_proto)
	_clear_element_nodes(_arrows, _arrow_proto)


func _clear_element_nodes(parent: Node, keep: Node) -> void:
	parent.remove_child(keep)
	for i in parent.get_children():
		parent.remove_child(i)
		i.queue_free()
	parent.add_child(keep)


func _load_image_list(sel_campaign: int, battle: int) -> void:
	var key := _native.get_battle_key_name(sel_campaign, battle)
	var def := _CObjectDef.instance().get_battle_def(key)
	if def == null:
		return
	_create_element_nodes(def.flag, "sflag_", _flag_proto)
	_create_element_nodes(def.arrow, "maparrow_", _arrow_proto)
	$Minimap/ImageList/Age/Label.text = def.age
	_age.position = Vector2(def.agex, def.agey)
	_center_pos = Vector2(def.centerx, def.centery)


func _create_element_nodes(data: Array[FlagInfo], image_prefix: String, prototype: Sprite2D) -> void:
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
		prototype.add_sibling(node)


func _clamp_pos(center_pos: Vector2) -> Vector2:
	center_pos *= _minimap.scale
	var minimap_size := _minimap.size * _minimap.scale
	var result := (center_pos - size / 2.0).max(Vector2.ZERO).min(minimap_size - size)
	if result.x < 0.0:
		result.x *= 0.5
	if result.y < 0.0:
		result.y *= 0.5
	return -result


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


func _on_button_info_pressed() -> void:
	_gui_battle_intro.campaign = campaign
	_gui_battle_intro.battle = _battle
	_gui_battle_intro.show()


func _on_gui_battle_intro_ok_pressed() -> void:
	_gui_battle_intro.hide()


func _on_gui_button_ok_pressed() -> void:
	g_GameManager.new_game(1, -1, campaign, _battle)
	ok_pressed.emit()


func _on_gui_button_back_pressed() -> void:
	back_pressed.emit()
