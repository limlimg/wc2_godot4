extends Control

## Techincal GUIElement exclusive to this port. Turn invisible and free itself
## if using 1024x768 view.

const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")

func _ready() -> void:
	if _ecGraphics.instance().content_scale_size_mode == 3:
		visible = false
		queue_free()
	else:
		if not has_node(^"../GUIiPad"):
			name = "GUIiPad"
