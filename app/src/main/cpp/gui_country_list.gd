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
var conquest: int:
	set(value):
		if value != conquest:
			conquest = value
			init()


var _selected_item := -1
var _id_list: Array[String]

signal country_selected(country: int)

func _ready() -> void:
	init()


func init() -> void:
	$GUIList.clear_item()
	_id_list.clear()
	var battle_file_name := _native.get_battle_file_name(2, 0, conquest)
	var belligerent_list := _native.get_battle_belligerent_list(battle_file_name, true)
	for belligerent in belligerent_list:
		$Factory/MarginContainer/GUICountryItem.country_name = belligerent.name
		$GUIList.add_item($Factory/MarginContainer.duplicate())
		_id_list.append(belligerent.id)
	set_select(0)


func _reset_select() -> void:
	for i in $GUIList.get_items():
		i.get_node(^"GUICountryItem").set_selected(false)


func set_select(index: int) -> void:
	_selected_item = index
	$GUIList.set_select(index)
	_reset_select()
	$GUIList.get_items()[index].get_node(^"GUICountryItem").set_selected(true)
	country_selected.emit(index)


func get_sel_country_id() -> String:
	if _selected_item < 0:
		return ""
	else:
		return _id_list[_selected_item]


func _on_gui_list_item_touched(index: int) -> void:
	set_select(index)
