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


var _bgs: Array[Sprite2D]

func init() -> void:
	for i in _bgs:
		i.queue_free()
	_bgs.clear()
	var areas_mark := _CAreaMark.new()
	areas_mark.map = map
	var map_full_size := areas_mark.get_map_size()
	var visible_rect := Rect2(position, size)
	@warning_ignore("integer_division")
	var col := (map_full_size.x + 499) / 500
	@warning_ignore("integer_division")
	for i in (map_full_size.y + 499) / 500:
		for j in col:
			var image_pos = Vector2(500 * j, 500 * i)
			if Rect2(image_pos, Vector2(500, 500)).intersects(visible_rect):
				var image := $Background/Sprite2D.duplicate()
				image.texture = image.texture.duplicate()
				image.texture.texture = _ecGraphics.instance().load_texture("map{0}_{1}.pkm".format([map, i * col + j + 1]))
				image.position = image_pos - position
				$Background.add_child(image)
				_bgs.append(image)
