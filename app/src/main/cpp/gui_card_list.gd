extends "res://app/src/main/cpp/gui/gui_list.gd"

const _CObjectDef = preload("res://app/src/main/cpp/c_object_def.gd")
const _GUICard = preload("res://app/src/main/cpp/gui_card.gd")

@export
var tab: int:
	set(value):
		if value != tab:
			tab = value
			for i in _items:
				i.queue_free()
			if is_node_ready():
				init()


var _selected := -1

signal card_selected(index: int)

func _ready() -> void:
	init()


func init() -> void:
	for i in 28:
		var card := _CObjectDef.instance().get_card_def(i)
		if card.type == tab:
			var node = $CTouchInertia/ScrollContainer/BoxContainer/GUICard.create_instance()
			node.def = card
			_items.append(node)


func re_select() -> void:
	var selected := _selected
	if selected >= 0:
		_reset_select()
		_set_select(selected)


func _set_select(index: int) -> void:
	_selected = index
	get_card(index).selected = true
	card_selected.emit(index)


func _reset_select() -> void:
	if _selected >= 0:
		get_card(_selected).selected = false
		_selected = -1


func get_card(index: int) -> _GUICard:
	if index >= _items.size():
		return null
	return _items[index]


func _on_gui_list_item_touched(item: int) -> void:
	if item >= 0 and item != _selected:
		_reset_select()
		_set_select(item)
