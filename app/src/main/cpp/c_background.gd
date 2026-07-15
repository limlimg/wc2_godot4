extends Control

const _CAreaMark = preload("res://app/src/main/cpp/c_area_mark.gd")
const _ecImageAttr = preload("res://app/src/main/cpp/ec_image_attr.gd")
const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")

@export
var map: int:
	set(value):
		if value != map:
			map = value
			init()


@export
var map_rect: Rect2:
	set(value):
		if value != map_rect:
			map_rect = value
			init()


@export
var scene_rect: Rect2:
	set(value):
		if value != scene_rect:
			scene_rect = value
			position = value.position - Vector2.ONE * 82.0
			size = value.size + Vector2.ONE * 164.0
			init()


var _bgs: Array[Sprite2D]

func init() -> void:
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
				image.texture.texture = _ecGraphics.instance().load_texture("map{0}_{1}.pkm".format([map, i * ceili(map_rect.size.x / 500) + j + 1]))
				image.position = image_pos - scene_rect.position
				$Background.add_child(image)
				_bgs.append(image)
			j += 1
		i += 1
