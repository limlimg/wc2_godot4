extends "res://app/src/main/cpp/gui_element.gd"

var _selected_tab: int

signal tab_selected(tab: int)

@onready var _list := [
	$HBoxContainer/Label/Control/GUIRadioButton,
	$HBoxContainer/Label2/Control/GUIRadioButton,
	$HBoxContainer/Label3/Control/GUIRadioButton,
	$HBoxContainer/Label4/Control/GUIRadioButton,
	$HBoxContainer/Label5/Control/GUIRadioButton
]

func _select_tab(tab: int) -> void:
	if tab != _selected_tab:
		if _selected_tab >= 0:
			var button = _list[_selected_tab]
			button.selected = false
			button.position.y = 0.0
			button.get_parent().get_parent().show_behind_parent = true
	_selected_tab = tab
	var selected_button = _list[tab]
	selected_button.selected = true
	selected_button.position.y = -12.0
	selected_button.get_parent().get_parent().show_behind_parent = false
	tab_selected.emit(tab)
