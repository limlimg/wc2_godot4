extends Control

var _bgs: Array[Sprite2D]

func init(map: int, map_rect: Rect2, scene_rect: Rect2) -> void:
	for i in _bgs:
		i.queue_free()
	_bgs.clear()
	@warning_ignore("narrowing_conversion")
	var i: int = map_rect.position.y / 500
	while i <= map_rect.end.y / 500:
		@warning_ignore("narrowing_conversion")
		var j: int = map_rect.position.x / 500
		while j <= map_rect.end.x / 500:
			var image_pos = Vector2(500 * j, 500 * i) + map_rect.position
			if Rect2(image_pos, Vector2(500, 500)).intersects(scene_rect):
				var image := $Background/Sprite2D.duplicate()
				image.texture = image.texture.duplicate()
				image.texture.texture = ecGraphics.instance().load_texture("map{0}_{1}.pkm".format([map, i * ceili(map_rect.size.x / 500) + j + 1]))
				image.position = image_pos - scene_rect.position
				$Background.add_child(image)
				_bgs.append(image)
			j += 1
		i += 1
	position = scene_rect.position - Vector2(82.0, 82.0)
	size = scene_rect.size + Vector2(164.0, 164.0)
