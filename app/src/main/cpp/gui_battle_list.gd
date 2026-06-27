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
			init()


var _selected_item := -1

signal battle_selected(battle: int)

func _ready() -> void:
	init()


func init() -> void:
	$GUIList.clear_item()
	var num_battles := _native.get_num_battles(campaign)
	var played_battles := num_battles
	if campaign != CAMPIAGN_MULTIPLAY:
		played_battles = g_Commander.get_num_played_battles(campaign)
	$Factory/MarginContainer/GUIBattleItem.campaign = campaign
	for i in num_battles:
		$Factory/MarginContainer/GUIBattleItem.battle = i
		$Factory/MarginContainer/GUIBattleItem.star = g_Commander.get_num_battle_stars(campaign, i)
		if i > played_battles:
			$Factory/MarginContainer/GUIBattleItem.set_enable(false)
			$Factory/MarginContainer/GUIBattleItem.locked = true
		$GUIList.add_item($Factory/MarginContainer.duplicate())


func _reset_select() -> void:
	for i in $GUIList.get_items():
		i.get_node(^"GUIBattleItem").set_selected(false)


func set_select(index: int) -> void:
	_selected_item = index
	$GUIList.set_select(index)
	_reset_select()
	$GUIList.get_items()[index].get_node(^"GUIBattleItem").set_selected(true)
	battle_selected.emit(index)


func select_last_unlocked() -> void:
	var a = $GUIList.get_items()
	var i = a.size()
	while i > 0:
		i -= 1
		var node := a[i].get_node(^"GUIBattleItem") as _GUIBattleItem
		if node != null and not node.locked:
			set_select(i)
			return


func _on_gui_list_item_touched(index: int) -> void:
	var item = $GUIList.get_items()[index].get_node(^"GUIBattleItem")
	if item is _GUIBattleItem and item.locked:
		return
	set_select(index)
