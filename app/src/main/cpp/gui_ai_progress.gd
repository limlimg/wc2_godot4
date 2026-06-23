extends "res://app/src/main/cpp/gui_element.gd"

const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")

@export
var cur_country_name: String:
	set = set_cur_country_name

@export
var progress: int:
	set(value):
		if value != progress:
			progress = value
			while $ProgressBar.get_child_count() < value:
				$ProgressBar.add_child($Prototype/TextureRect.duplicate())
			while $ProgressBar.get_child_count() > value:
				var c := $ProgressBar.get_child(0)
				$ProgressBar.remove_child(c)
				c.queue_free()


func set_cur_country_name(value):
	if value != cur_country_name:
		cur_country_name = value
		var image := g_GameRes.get_flag_image("flag_{0}.png".format([value]))
		if image != null:
			$Flag.texture = _ecImageTexture.from_ec_image_attr(image)
		else:
			$Flag.texture = null
