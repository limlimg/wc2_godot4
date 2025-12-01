extends Control

## Techincal GUIElement exclusive to this port. Invisible by default. Turn
## visible if using 1024x768 view. Otherwise free itself.

const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")
const _GUIIpadElse = preload("res://app/src/main/cpp/scene_system_resource/gui_ipad_else.gd")

func _ready() -> void:
	if _ecGraphics.instance().content_scale_size_mode == 3:
		visible = true
	else:
		var old_name := name
		name = "GUIiPadFalse"
		var parent := get_parent()
		if parent != null:
			for else_node in parent.get_children():
				if else_node is _GUIIpadElse:
					else_node.name = old_name
					break
		queue_free()
