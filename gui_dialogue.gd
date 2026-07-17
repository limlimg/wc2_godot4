extends GUIElement

signal pressed

func show_dlg(dlg: String, general: StringName, _left: bool) -> void:
	var photo := CObjectDef.instance().get_general_photo(general)
	if photo == null:
		return
	$General/TextureRect.texture = ecGraphics.instance().load_texture(photo.filename)
	$Dlg/Label.text = dlg
	show()


func hide_dlg() -> void:
	hide()


func _on_button_pressed() -> void:
	hide_dlg()
	pressed.emit()
