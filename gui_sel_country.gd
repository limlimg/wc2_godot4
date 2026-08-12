extends GUIElement

@export
var conquest: int:
	set(value):
		if value != conquest:
			conquest = value
			$GUICountryList.conquest = value
			init()


var _country := -1

signal ok_pressed
signal back_pressed

func init() -> void:
	if not is_node_ready():
		return
	super()
	if ecGraphics.instance().content_scale_size_mode == 3:
		s_texture_res.load_res("selcountry_hd.xml", false)
	elif EC2dAppDelegate.g_content_scale_factor == 2.0:
		s_texture_res.load_res("selcountry_hd.xml", true)
	else:
		s_texture_res.load_res("selcountry.xml", false)
	_country = -1
	_load_image_list(conquest)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if ecGraphics.instance().content_scale_size_mode == 3:
			s_texture_res.unload_res("selcountry_hd.xml")
		elif EC2dAppDelegate.g_content_scale_factor == 2.0:
			s_texture_res.unload_res("selcountry_hd.xml")
		else:
			s_texture_res.unload_res("selcountry.xml")


func _load_image_list(sel_conquest: int) -> void:
	var key = AppDelegate.get_conquest_key_name(sel_conquest)
	var def := CObjectDef.instance().get_conquest_def(key)
	if def == null:
		return
	var arrows: Array[FlagInfo]
	$GUISelBattleCommon.set_image_list(def.flag, arrows, "", Vector2.ZERO, Vector2(def.centerx, def.centery))


func _on_gui_country_list_country_selected(country: int) -> void:
	_country = country


func _on_button_ok_pressed() -> void:
	g_GameManager.new_game(2, -1, 0, conquest)
	g_GameManager.set_conquest_player_country_id($GUICountryList.get_sel_country_id())
	ok_pressed.emit()


func _on_button_back_pressed() -> void:
	back_pressed.emit()


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
	elif event.is_action_released(&"ui_cancel"):
		back_pressed.emit()
		accept_event()
