extends "res://app/src/main/cpp/native-lib.gd"

## The .raw file is imported as Image and it is also possible to use an actual
## image. Open raw_color_calculator.tres in assets tools in the inspector to see
## the color schema.

var mark_size := Vector2i(8, 8)
var pattern_size: Vector2i
var _pattern: Image

func init(map: int) -> void:
	release()
	_pattern = load(get_path("areamark{0}.raw".format([map]), "")) as Image
	if _pattern == null:
		return
	pattern_size = _pattern.get_size()


func release() -> void:
	_pattern = null


func get_mark(x: int, y: int) -> int:
	x /= mark_size.x
	y /= mark_size.y
	if _pattern == null or x < 0 or x >= pattern_size.x or y < 0 or y >= pattern_size.y:
		return -1
	return color_to_id(_pattern.get_pixel(x, y))


static func id_to_color(id: int) -> Color:
	var rgb8 := (332881 * id - 1) & 0xFFFFFF
	var r8 := (rgb8 >> 16) & 0xFF
	var g8 := (rgb8 >> 8) & 0xFF
	var b8 := rgb8 & 0xFF
	return Color.from_rgba8(r8, g8, b8)


static func color_to_id(color: Color) -> int:
	var rgb8 := (color.r8 << 16) | (color.g8 << 8) | color.b8
	return (16037041 * (rgb8 + 1)) & 0xFFFFFF
