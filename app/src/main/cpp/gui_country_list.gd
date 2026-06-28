extends "res://app/src/main/cpp/gui/gui_list.gd"

# ResetTouchState is unused and not implemented.

const _lib = preload("res://app/src/main/cpp/native-lib.gd")

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
			for i in _items:
				$CTouchInertia/ScrollContainer/BoxContainer.remove_child(i)
				i.queue_free()
			init()


var _items: Array[Control]

signal country_selected(country: int)

func _ready() -> void:
	init()


func init() -> void:
	var battle_file_name := _lib.get_battle_file_name(2, 0, conquest)
	var belligerent_list := _lib.get_battle_belligerent_list(battle_file_name, true)
	for belligerent in belligerent_list:
		var item = $CTouchInertia/ScrollContainer/BoxContainer/GUICountryItem.create_instance()
		item.country_name = belligerent.name
		_items.append(item)
	set_select(0)


func _reset_select() -> void:
	for i in _items:
		i.set_selected(false)


func set_select(index: int) -> void:
	super(index)
	_reset_select()
	_items[index].set_selected(true)
	country_selected.emit(index)


func get_sel_country_id() -> String:
	if _selected_item < 0:
		return ""
	else:
		return _items[_selected_item].country_name


func _on_item_touched(index: int) -> void:
	set_select(index)
