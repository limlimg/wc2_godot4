
## In the original game code, touch indexes are available from the system, but
## they are discarded and this class maintain another touch indexes by closest
## match.

const _ecMultipleTouch = preload("res://app/src/main/cpp/ec_multiple_touch.gd")

class Touch:
	var index: int
	var position: Vector2
	var moved: bool

static var _instance := _ecMultipleTouch.new()
static var _next_touch_index := 0

var _touch_list: Array[Touch]

static func instance() -> _ecMultipleTouch:
	return _instance


func reset() -> void:
	_touch_list.clear()


func touch_began(x: float, y: float) -> int:
	_next_touch_index += 1
	var touch := Touch.new()
	touch.index = _next_touch_index
	touch.position.x = x
	touch.position.y = y
	touch.moved = false
	_touch_list.append(touch)
	return _next_touch_index


func touch_moved(x: float, y: float) -> int:
	var pos := Vector2(x, y)
	var touch := _find_closest(pos)
	if touch == null:
		return -1
	touch.position = pos
	touch.moved = true
	return touch.index


func touch_ended(x: float, y: float) -> int:
	var pos := Vector2(x, y)
	var touch := _find_closest(pos)
	if touch == null:
		return -1
	_touch_list.erase(touch)
	return touch.index


func _find_closest(pos: Vector2) -> Touch:
	return _touch_list.reduce(func(s, x): 
		return s if pos.distance_squared_to(s) < pos.distance_squared_to(x) else x
	)
