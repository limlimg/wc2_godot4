extends "res://app/src/main/cpp/gui_element.gd"

const _CObjectDef = preload("res://app/src/main/cpp/c_object_def.gd")

signal pressed

func show_dlg(dlg: String, general: StringName, _left: bool) -> void:
	var photo := _CObjectDef.instance().get_general_photo(general)
	if photo == null:
		return
	$General/TextureRect.texture = _ecGraphics.instance().load_texture(photo.filename)
	$Dlg/Label.text = dlg
	show()


func hide_dlg() -> void:
	hide()


func _on_button_pressed() -> void:
	hide_dlg()
	pressed.emit()
