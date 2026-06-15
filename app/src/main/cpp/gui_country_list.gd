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

signal country_selected(country: int)

func _ready() -> void:
	init()


func init() -> void:
	$GUIList.clear_item()
	var battle_file_name := _native.get_battle_file_name(2, 0, conquest)
	var belligerent_list := _native.get_battle_belligerent_list(battle_file_name, true)
	var item_proto: MarginContainer = $Prototype/GUICountryItem
	for belligerent in belligerent_list:
		var item := item_proto.duplicate()
		$GUIList.add_item(item)
		item.country_name = belligerent.name
	set_select(0)


func _reset_select() -> void:
	for i in $GUIList.get_items():
		i.set_selected(false)


func set_select(index: int) -> void:
	_selected_item = index
	$GUIList.set_select(index)
	_reset_select()
	$GUIList.get_items()[index].set_selected(true)
	country_selected.emit(index)


func _on_gui_list_item_touched(index: int) -> void:
	set_select(index)
