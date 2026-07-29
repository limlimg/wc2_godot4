extends GUIElement

var _selected_tab: int

signal tab_selected(tab: int)

@onready var _list := [
	$GUIElement/HBoxContainer/GUIRadioButton,
	$GUIElement/HBoxContainer/GUIRadioButton2,
	$GUIElement/HBoxContainer/GUIRadioButton3,
	$GUIElement/HBoxContainer/GUIRadioButton4,
	$GUIElement/HBoxContainer/GUIRadioButton5
]

func _select_tab(tab: int) -> void:
	if tab != _selected_tab:
		if _selected_tab >= 0:
			var button = _list[_selected_tab]
			button.selected = false
			button.position.y = 0.0
			button.show_behind_parent = true
	_selected_tab = tab
	var selected_button = _list[tab]
	selected_button.selected = true
	selected_button.position.y = -12.0
	selected_button.show_behind_parent = false
	tab_selected.emit(tab)
