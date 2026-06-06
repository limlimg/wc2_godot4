extends "res://app/src/main/cpp/gui_element.gd"

# ResetTouchState is unused and not implemented.

const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _GUIBattleItem = preload("res://app/src/main/cpp/gui_battle_item.gd")
const CAMPIAGN_AXIS = 0
const CAMPIAGN_ALLIES = 1
const CAMPIAGN_WTO = 2
const CAMPIAGN_NATO = 3
const CAMPIAGN_MULTIPLAY = 4

@export
var campaign: int:
	set(value):
		if value != campaign:
			campaign = value
			if is_node_ready():
				init()


var _selected_item := -1
var _scoll_vertical := 0.0

@onready
var _scroll := $CTouchInertia/ScrollContainer as ScrollContainer

@onready
var _list := $CTouchInertia/ScrollContainer/VBoxContainer as VBoxContainer

signal battle_selected(battle: int)

func _ready() -> void:
	init()


func init() -> void:
	var container := _list
	for c in container.get_children():
		container.remove_child(c)
		c.queue_free()
	var num_battles := _native.get_num_battles(campaign)
	var played_battles := num_battles
	if num_battles != CAMPIAGN_MULTIPLAY:
		played_battles = g_Commander.get_num_played_battles(campaign)
	var item_scene = load("res://app/src/main/cpp/gui_battle_item.tscn")
	for i in num_battles:
		var item := item_scene.instantiate() as _GUIBattleItem
		container.add_child(item)
		item.campaign = campaign
		item.battle = i
		item.star = g_Commander.get_num_battle_stars(campaign, i)
		if i > played_battles:
			item.set_enable(false)
			item.locked = true


func _reset_select() -> void:
	for i in _list.get_children():
		i.set_selected(false)
		i.z_index = 0


func set_select(index: int) -> void:
	_selected_item = index
	_list.get_children()[index].set_selected(true)
	_list.get_children()[index].z_index = 1
	battle_selected.emit(index)


func select_last_unlocked() -> void:
	var a := _list.get_children().duplicate()
	var i := a.size()
	while i > 0:
		i -= 1
		if a[i] is _GUIBattleItem and not a[i].locked:
			set_select(i)
			return


func _on_c_touch_inertia_touch_began(_position: Vector2) -> void:
	set_physics_process(false)


func _on_c_touch_inertia_touch_ended(pos: Vector2, moved: bool) -> void:
	if not moved:
		pos = get_global_transform() * pos
		var sel_item := _gel_sel_item(pos.x, pos.y)
		if sel_item >= 0 and sel_item != _selected_item:
			_reset_select()
			set_select(sel_item)


func _gel_sel_item(x: float, y: float) -> int:
	var a := _list.get_children()
	for i in a.size():
		if a[i] is _GUIBattleItem and not a[i].locked and a[i].check_in_rect(x, y):
			return i
	return -1


func _on_c_touch_inertia_inertia_ended() -> void:
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	var y := (_scroll as ScrollContainer).position.y
	if y < 0.0:
		_add_scroll_vertial(min(y * delta * 5.0, -0.4))
	elif y > 0.0:
		_add_scroll_vertial(max(y * delta * 5.0, 0.4))
	else:
		set_physics_process(false)


func _on_c_touch_inertia_touch_moved(relative: Vector2) -> void:
	_add_scroll_vertial(-relative.y)


func _add_scroll_vertial(delta: float) -> void:
	if delta == 0.0:
		return
	if (_scoll_vertical + _scroll.position.y) as int != _scroll.scroll_vertical:
		_scoll_vertical = _scroll.scroll_vertical as float - _scroll.position.y
	_scoll_vertical += delta
	var scroll_bar := _scroll.get_v_scroll_bar()
	var scroll_min := scroll_bar.min_value
	if _scoll_vertical < scroll_min:
		_scroll.scroll_vertical = scroll_min as int
		_scroll.position.y = scroll_min - _scoll_vertical
	else:
		var scroll_max := scroll_bar.max_value - scroll_bar.page
		if _scoll_vertical > scroll_max:
			_scroll.scroll_vertical = scroll_max as int
			_scroll.position.y = scroll_max - _scoll_vertical
		else:
			_scroll.scroll_vertical = _scoll_vertical as int
			_scroll.position.y = 0.0
