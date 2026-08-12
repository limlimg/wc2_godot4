extends GUIElement

signal pressed

func show_dlg(dlg: String, general: StringName, _left: bool) -> void:
	var photo := CObjectDef.instance().get_general_photo(general)
	if photo == null:
		return
	var image := ecImageAttr.new()
	image.texture = ecGraphics.instance().load_texture(photo.filename)
	image.region = Rect2(0.0, 0.0, photo.w, photo.h)
	image.origin = Vector2(photo.refx, photo.h)
	$General/TextureRect.texture = image
	$Dlg/Font8/Label.text = dlg
	show()


func _hide_dlg() -> void:
	hide()


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if event is InputEventScreenTouch:
			if not event.pressed:
				_hide_dlg()
				pressed.emit()
		accept_event()
