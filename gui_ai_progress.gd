extends GUIElement

@export
var cur_country_name: String:
	set = set_cur_country_name

@export
var progress: int:
	set(value):
		if value != progress:
			progress = value
			while _bars.size() < value:
				_bars.append($ProgressBar/Prototype.duplicate())
				_bars[-1].visible = true
				$ProgressBar.add_child(_bars[-1])
			while _bars.size() > value:
				_bars.pop_back().queue_free()


var _bars: Array[TextureRect]

func set_cur_country_name(value):
	if value != cur_country_name:
		cur_country_name = value
		var image = g_GameRes.get_flag_image("flag_{0}.png".format([value]))
		if image != null:
			$Flag.texture = image
		else:
			$Flag.texture = null
