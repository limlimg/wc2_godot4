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

@onready var _list: Control = $GUIList

signal battle_selected(battle: int)

func _ready() -> void:
	init()


func init() -> void:
	_list.clear_item()
	var num_battles := _native.get_num_battles(campaign)
	var played_battles := num_battles
	if campaign != CAMPIAGN_MULTIPLAY:
		played_battles = g_Commander.get_num_played_battles(campaign)
	var item_proto: MarginContainer = $Prototype/GUIBattleItem
	item_proto.campaign = campaign
	for i in num_battles:
		var item := item_proto.duplicate()
		_list.add_item(item)
		item.battle = i
		item.star = g_Commander.get_num_battle_stars(campaign, i)
		if i > played_battles:
			item.set_enable(false)
			item.locked = true


func _reset_select() -> void:
	for i in _list.get_items():
		i.set_selected(false)
		i.z_index = 0


func set_select(index: int) -> void:
	_list.set_select(index)


func select_last_unlocked() -> void:
	var a = _list.get_items()
	var i = a.size()
	while i > 0:
		i -= 1
		if a[i] is _GUIBattleItem and not a[i].locked:
			set_select(i)
			return


func _on_gui_list_item_selected(index: int) -> void:
	_reset_select()
	_selected_item = index
	var item = _list.get_items()[index]
	item.set_selected(true)
	item.z_index = 1
	battle_selected.emit(index)
