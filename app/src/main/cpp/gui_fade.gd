extends "res://app/src/main/cpp/gui_element.gd"

## This node corresponds to a call to ecGraphics::Fade in GUIElement::OnRender.

@export
var alpha := 0.5:
	set(value):
		alpha = value
		_set_fade_color()


func _ready() -> void:
	init()


func init() -> void:
	var graphics := _ecGraphics.instance()
	_set_fade_color()
	graphics.fade_color_changed.connect(_set_fade_color)


func _set_fade_color() -> void:
	var color := _ecGraphics.instance().fade_color
	color.a = alpha
	$ColorRect.color = color
