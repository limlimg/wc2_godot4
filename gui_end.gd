extends GUIElement

@export
var campaign: int:
	set(value):
		if value != campaign:
			campaign = value
			init()


var _bg: Node

signal back_pressed

func init() -> void:
	if not is_node_ready():
		return
	super()
	if _bg != null:
		_bg.queue_free()
	match campaign:
		0:
			_bg = $FixedWidth/VictoryBgAxis.create_instance()
			$FixedWidth/TextVictroy/ecUniFont/Label.text = "victory axis"
		1:
			_bg = $FixedWidth/VictoryBgAllies.create_instance()
			$FixedWidth/TextVictroy/ecUniFont/Label.text = "victory allies"
		2:
			_bg = $FixedWidth/VictoryBgWto.create_instance()
			$FixedWidth/TextVictroy/ecUniFont/Label.text = "victory wto"
		3:
			_bg = $FixedWidth/VictoryBgNato.create_instance()
			$FixedWidth/TextVictroy/ecUniFont/Label.text = "victory nato"


func _on_gui_button_back_pressed() -> void:
	back_pressed.emit()


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
	elif event.is_action_released(&"ui_cancel"):
		$FixedWidth/ButtonBack.pressed.emit()
		accept_event()
