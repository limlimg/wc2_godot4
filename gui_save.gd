extends GUIElement

@export
var game_mode: int:
	set(value):
		if value != game_mode:
			game_mode = value
			_update_items()


@export
var loading: bool:
	set(value):
		if value != loading:
			loading = value
			_update_enable()


var _selected := -1

@onready var _list := [$Control/SaveItem/GUISaveItem, $Control/SaveItem2/GUISaveItem, $Control/SaveItem3/GUISaveItem, $Control/SaveItem4/GUISaveItem, $Control/SaveItem5/GUISaveItem, $Control/SaveItem6/GUISaveItem, $Control/AutoSaveItem/GUIAutoSaveItem]

signal ok_pressed

func _ready() -> void:
	_update_items()


func _update_items() -> void:
	for i in _list.size():
		var save_name: String
		if game_mode == 2:
			save_name = "conquest{0}.sav".format([i])
		else:
			save_name = "game{0}.sav".format([i])
		var header := g_GameManager.get_save_header(save_name)
		if header != null:
			var country: String
			if header.game_mode == 4:
				country = "1v1"
			else:
				country = header.player_country_name[0]
			_list[i].country = country
			_list[i].game_mode = header.game_mode
			_list[i].campaign = header.campaign
			_list[i].battle = header.battle
			_list[i].year = header.save_time_year
			_list[i].month = header.save_time_month
			_list[i].day = header.save_time_day
			_list[i].hour = header.save_time_hour
			_list[i].minute = header.save_time_min
	_update_enable()
	_selected = -1
	$ButtonOk/GUIButton.enable = false


func _update_enable() -> void:
	if loading:
		$Control/SaveItem/GUISaveItem.enable = not $Control/SaveItem/GUISaveItem.empty
		$Control/SaveItem2/GUISaveItem.enable = not $Control/SaveItem2/GUISaveItem.empty
		$Control/SaveItem3/GUISaveItem.enable = not $Control/SaveItem3/GUISaveItem.empty
		$Control/SaveItem4/GUISaveItem.enable = not $Control/SaveItem4/GUISaveItem.empty
		$Control/SaveItem5/GUISaveItem.enable = not $Control/SaveItem5/GUISaveItem.empty
		$Control/SaveItem6/GUISaveItem.enable = not $Control/SaveItem6/GUISaveItem.empty
		$Control/AutoSaveItem/GUIAutoSaveItem.enable = not $Control/AutoSaveItem/GUIAutoSaveItem.empty
	else:
		$Control/SaveItem/GUISaveItem.enable = true
		$Control/SaveItem2/GUISaveItem.enable = true
		$Control/SaveItem3/GUISaveItem.enable = true
		$Control/SaveItem4/GUISaveItem.enable = true
		$Control/SaveItem5/GUISaveItem.enable = true
		$Control/SaveItem6/GUISaveItem.enable = true
		$Control/AutoSaveItem/GUIAutoSaveItem.enable = false


func _on_gui_save_item_pressed(item: int) -> void:
	_sel_item(item)


func _sel_item(item: int) -> void:
	_selected = item
	for i in _list.size():
		_list[i].selected = i == item
		_list[i].get_parent().show_behind_parent = i == item
	$ButtonOk/GUIButton.enable = true


func _on_gui_button_ok_pressed() -> void:
	if loading:
		if _selected <= 6:
			var save := "conquest{0}.sav" if game_mode == 2 else "game{0}.sav"
			save = save.format([_selected])
			if g_GameManager.get_save_header(save) != null:
				g_GameManager.load_game(save)
				ok_pressed.emit()


func _on_gui_button_back_pressed() -> void:
	back_pressed.emit()
