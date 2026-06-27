extends "res://app/src/main/cpp/gui_element.gd"

const _CCountry = preload("res://app/src/main/cpp/c_country.gd")
const _CObjectDef = preload("res://app/src/main/cpp/c_object_def.gd")
const _SndEffect = preload("res://app/src/main/cpp/snd_effect.gd").SND_EFFECT

@export
var texture_res: _ecTextureRes

@export
var flag_texture_res: _ecTextureRes

var _tween_auto_close: Tween

signal ok_pressed

func show_defeated(country: _CCountry) -> void:
	if texture_res != null and country != null:
		$Flag.texture = flag_texture_res.get_image("flag_{0}.png".format([country.name]))
	else:
		$Flag.texture = null
	if country.ai:
		var commander_name := country.get_commander_name()
		if not commander_name.is_empty():
			var photo := _CObjectDef.instance().get_general_photo(commander_name)
			if photo != null:
				$General.texture = texture_res.get_image(commander_name.left(commander_name.rfind(".")) + ".png")
			else:
				$General.texture = texture_res.get_image("general_common.png")
	else:
		$General.texture = texture_res.get_image("general_player.png")
	show()
	if g_GameManager.game_mode == 4:
		_tween_auto_close = create_tween()
		_tween_auto_close.tween_interval(5.0)
		_tween_auto_close.tween_callback(_on_button_ok_pressed)
	g_SoundRes.play_char_se(_SndEffect.POP_WAV)


func hide_defeated() -> void:
	hide()
	if _tween_auto_close != null:
		_tween_auto_close.kill()
		_tween_auto_close = null


func _on_button_ok_pressed() -> void:
	ok_pressed.emit()
