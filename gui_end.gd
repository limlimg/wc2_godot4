extends GUIElement

@export
var campaign: int:
	set(value):
		if value != campaign:
			campaign = value
			if is_node_ready():
				init()


var _bg: TextureRect

func init() -> void:
	if not is_node_ready():
		return
	super()
	if _bg != null:
		_bg.queue_free()
	match campaign:
		0:
			_bg = $FixedWidth/GUIEndAxis.create_instance()
		1:
			_bg = $FixedWidth/GUIEndAllies.create_instance()
		2:
			_bg = $FixedWidth/GUIEndWto.create_instance()
		3:
			_bg = $FixedWidth/GUIEndNato.create_instance()


func _on_gui_button_back_pressed() -> void:
	back_pressed.emit()
