extends Control

## Techincal GUIElement exclusive to this port. Invisible by default. Turn
## visible if using 1024x768 view. Otherwise free itself.

const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")

func _ready() -> void:
	if _ecGraphics.instance().content_scale_size_mode == 3:
		visible = true
	else:
		name = "GUIiPadFalse"
		var else_node := get_node_or_null(^"../GUIiPadElse")
		if else_node != null:
			else_node.name = "GUIiPad"
		queue_free()
