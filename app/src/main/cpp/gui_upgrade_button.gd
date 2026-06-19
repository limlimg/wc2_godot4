extends "res://app/src/main/cpp/gui_button.gd"

@export
var need_medal: int:
	set = set_need_medal

func set_need_medal(value: int) -> void:
	if value != need_medal:
		need_medal = value
		$GUIRect/Control/HBoxContainer/NeedMedal.text = "{0}".format([value])


func _on_render():
	if enable:
		if $TextureButton.button_pressed:
			$TextureButton.self_modulate = Color(Color8(0xD2, 0xD2, 0xD2), alpha)
		else:
			$TextureButton.self_modulate = Color(Color.WHITE, alpha)
	else:
			$TextureButton.self_modulate = Color(Color8(0x6E, 0x6E, 0x6E), alpha)
