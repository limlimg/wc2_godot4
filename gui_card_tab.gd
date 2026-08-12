extends GUIElement

var _selected_tab: int

signal tab_selected(tab: int)

@onready var _list := [
	$GUIElement/HBoxContainer/Control,
	$GUIElement/HBoxContainer/Control2,
	$GUIElement/HBoxContainer/Control3,
	$GUIElement/HBoxContainer/Control4,
	$GUIElement/HBoxContainer/Control5
]

func init() -> void:
	if not is_node_ready():
		return
	super()
	_select_tab(0)


func _select_tab(tab: int) -> void:
	if tab != _selected_tab:
		if _selected_tab >= 0:
			var button = _list[_selected_tab]
			button.get_node(^"GUIRadioButton").selected = false
			button.get_node(^"GUIRadioButton").position.y = 0.0
			button.show_behind_parent = true
	_selected_tab = tab
	var selected_button = _list[tab]
	selected_button.get_node(^"GUIRadioButton").selected = true
	selected_button.get_node(^"GUIRadioButton").position.y = -12.0
	selected_button.show_behind_parent = false


func _on_gui_radio_button_pressed(tab: int) -> void:
	_select_tab(tab)
	tab_selected.emit(tab)
