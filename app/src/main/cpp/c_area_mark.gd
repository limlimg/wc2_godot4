extends Resource

## The .raw file is imported as Image and it is also possible to use an actual
## image. Open raw_color_calculator.tres in assets tools in the inspector to see
## the color schema.

const _lib = preload("res://app/src/main/cpp/native-lib.gd")

@export
var map: int:
	set(value):
		if value != map:
			map = value
			init()


var mark_size := Vector2i(8, 8)
var _pattern: Image

func init() -> void:
	release()
	_pattern = load(_lib.get_asset_path("areamark{0}.raw".format([map]), "")) as Image


func release() -> void:
	_pattern = null


func get_mark(x: int, y: int) -> int:
	x /= mark_size.x
	y /= mark_size.y
	if _pattern == null or x < 0 or x >= _pattern.get_width() or y < 0 or y >= _pattern.get_height():
		return -1
	return color_to_id(_pattern.get_pixel(x, y))


func get_map_size() -> Vector2i:
	if _pattern == null:
		return Vector2i.ZERO
	return _pattern.get_size() * mark_size


static func id_to_color(id: int) -> Color:
	var rgb8 := (332881 * id - 1) & 0xFFFFFF
	var r8 := (rgb8 >> 16) & 0xFF
	var g8 := (rgb8 >> 8) & 0xFF
	var b8 := rgb8 & 0xFF
	return Color.from_rgba8(r8, g8, b8)


static func color_to_id(color: Color) -> int:
	var rgb8 := (color.r8 << 16) | (color.g8 << 8) | color.b8
	return (16037041 * (rgb8 + 1)) & 0xFFFFFF
