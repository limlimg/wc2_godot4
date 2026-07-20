extends GUIElement

@export
var conquest: int:
	get():
		return $GUICountryList/GUICountryList.conquest
	set(value):
		if value != conquest:
			$GUICountryList/GUICountryList.conquest = value
			init()


var _country := -1

signal ok_pressed

func _ready() -> void:
	init()


func init() -> void:
	#s_texture_res = load("res://scene_system_resource/selcountry_res/texture_res.tres").get_res()
	_country = -1
	_load_image_list(conquest)


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
	g_GameManager.set_conquest_player_country_id($GUICountryList/GUICountryList.get_sel_country_id())
	ok_pressed.emit()


func _on_button_back_pressed() -> void:
	back_pressed.emit()
