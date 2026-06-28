extends "res://app/src/main/cpp/gui/gui_list.gd"

# ResetTouchState is unused and not implemented.

const _lib = preload("res://app/src/main/cpp/native-lib.gd")
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
			for i in _items:
				$CTouchInertia/ScrollContainer/BoxContainer.remove_child(i)
				i.queue_free()
			init()


var _items: Array[_GUIBattleItem]

signal battle_selected(battle: int)

func _ready() -> void:
	init()


func init() -> void:
	var num_battles := _lib.get_num_battles(campaign)
	var played_battles := num_battles
	if campaign != CAMPIAGN_MULTIPLAY:
		played_battles = g_Commander.get_num_played_battles(campaign)
	for i in num_battles:
		var item = $CTouchInertia/ScrollContainer/BoxContainer/GUIBattleItem.create_instance()
		item.campaign = campaign
		item.battle = i
		item.star = g_Commander.get_num_battle_stars(campaign, i)
		if i > played_battles:
			item.set_enable(false)
			item.locked = true
		_items.append(item)


func _reset_select() -> void:
	for i in _items:
		i.set_selected(false)


func set_select(index: int) -> void:
	super(index)
	_reset_select()
	_items[index].set_selected(true)
	battle_selected.emit(index)


func select_last_unlocked() -> void:
	var i = _items.size()
	while i > 0:
		i -= 1
		var item := _items[i]
		if item != null and not item.locked:
			set_select(i)
			return


func _on_item_touched(index: int) -> void:
	var item = _items[index]
	if item.locked:
		return
	set_select(index)
