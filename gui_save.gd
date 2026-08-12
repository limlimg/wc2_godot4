extends GUIElement

@export
var game_mode: int:
	set(value):
		if value != game_mode:
			game_mode = value
			init()


@export
var loading: bool:
	set(value):
		if value != loading:
			loading = value
			_update_enable()


var _selected := -1

@onready var _list := [$GUISaveItem, $GUISaveItem2, $GUISaveItem3, $GUISaveItem4, $GUISaveItem5, $GUISaveItem6, $GUIAutoSaveItem]

signal ok_pressed
signal back_pressed

func init() -> void:
	if not is_node_ready():
		return
	super()
	if ecGraphics.instance().content_scale_size_mode == 3:
		s_texture_res.load_res("flag_hd.xml", false)
	elif EC2dAppDelegate.g_content_scale_factor == 2.0:
		s_texture_res.load_res("flag_hd.xml", true)
	else:
		s_texture_res.load_res("flag.xml", false)
	for i in _list.size():
		var save_name: String
		if game_mode == 2:
			save_name = "conquest{0}.sav".format([i])
		else:
			save_name = "game{0}.sav".format([i])
		var header = g_GameManager.get_save_header(save_name)
		if header != null:
			_list[i].empty = false
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
	$ButtonOk.enable = false


func _update_enable() -> void:
	if loading:
		$GUISaveItem.enable = not $GUISaveItem.empty
		$GUISaveItem2.enable = not $GUISaveItem2.empty
		$GUISaveItem3.enable = not $GUISaveItem3.empty
		$GUISaveItem4.enable = not $GUISaveItem4.empty
		$GUISaveItem5.enable = not $GUISaveItem5.empty
		$GUISaveItem6.enable = not $GUISaveItem6.empty
		$GUIAutoSaveItem.enable = not $GUIAutoSaveItem.empty
	else:
		$GUISaveItem.enable = true
		$GUISaveItem2.enable = true
		$GUISaveItem3.enable = true
		$GUISaveItem4.enable = true
		$GUISaveItem5.enable = true
		$GUISaveItem6.enable = true
		$GUIAutoSaveItem.enable = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if ecGraphics.instance().content_scale_size_mode == 3:
			s_texture_res.unload_res("flag_hd.xml")
		elif EC2dAppDelegate.g_content_scale_factor == 2.0:
			s_texture_res.unload_res("flag_hd.xml")
		else:
			s_texture_res.unload_res("flag.xml")


func _on_gui_save_item_pressed(source: Node) -> void:
	_sel_item(_list.find(source))


func _sel_item(item: int) -> void:
	_selected = item
	for i in _list.size():
		_list[i].selected = i == item
		_list[i].get_parent().show_behind_parent = i == item
	$ButtonOk.enable = true


func _on_gui_button_ok_pressed() -> void:
	if loading:
		if _selected <= 6:
			var save := "conquest{0}.sav" if game_mode == 2 else "game{0}.sav"
			save = save.format([_selected])
			if g_GameManager.get_save_header(save) != null:
				g_GameManager.load_game(save)
				ok_pressed.emit()
	else:
		if _selected <= 5:
			var save := "conquest{0}.sav" if game_mode == 2 else "game{0}.sav"
			save = save.format([_selected])
			g_GameManager.save_game(save)
			ok_pressed.emit()


func _on_gui_button_back_pressed() -> void:
	back_pressed.emit()


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
	if event.is_action_released(&"ui_cancel"):
		back_pressed.emit()
		accept_event()
