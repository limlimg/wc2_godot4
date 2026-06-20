extends "res://app/src/main/cpp/gui_element.gd"

const _GUIManager = preload("res://app/src/main/cpp/gui_manager.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")
const _ecImage = preload("res://app/src/main/cpp/ec_image.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _GUIBattleList = preload("res://app/src/main/cpp/gui_battle_list.gd")
const _CObjectDef = preload("res://app/src/main/cpp/c_object_def.gd")
const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")
const _FlagInfo = preload("res://app/src/main/cpp/flag_info.gd")

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
signal back_pressed

func _ready() -> void:
	init()


func init() -> void:
	#s_texture_res = load("res://app/src/main/cpp/scene_system_resource/selcountry_res/texture_res.tres").get_res()
	_country = -1
	_load_image_list(conquest)


func _load_image_list(sel_conquest: int) -> void:
	var key := _native.get_conquest_key_name(sel_conquest)
	var def := _CObjectDef.instance().get_conquest_def(key)
	if def == null:
		return
	var arrows: Array[_FlagInfo]
	$GUISelBattleCommon.set_image_list(def.flag, arrows, "", Vector2.ZERO, Vector2(def.centerx, def.centery))


func _on_gui_country_list_country_selected(country: int) -> void:
	_country = country


func _on_button_ok_pressed() -> void:
	g_GameManager.new_game(2, -1, 0, conquest)
	g_GameManager.set_conquest_player_country_id($GUICountryList/GUICountryList.get_sel_country_id())
	ok_pressed.emit()


func _on_button_back_pressed() -> void:
	back_pressed.emit()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		back_pressed.emit()
