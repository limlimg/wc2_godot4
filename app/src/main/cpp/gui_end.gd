extends "res://app/src/main/cpp/gui_element.gd"

@export
var campaign: int:
	set(value):
		if value != campaign:
			campaign = value
			if is_node_ready():
				init()


var _bg: TextureRect

func _ready() -> void:
	init()


func init() -> void:
	if _bg != null:
		_bg.queue_free()
	match campaign:
		0:
			_bg = $GUIEndAxis.create_instance()
		1:
			_bg = $GUIEndAllies.create_instance()
		2:
			_bg = $GUIEndWto.create_instance()
		3:
			_bg = $GUIEndNato.create_instance()


func _on_gui_button_back_pressed() -> void:
	back_pressed.emit()
