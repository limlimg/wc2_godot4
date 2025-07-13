extends Resource # To use Resource.duplicate

const ACTION_MASK = 0x000000ff
const ACTION_DOWN = 0
const ACTION_UP = 1
const ACTION_MOVE = 2
const ACTION_CANCEL = 3
const ACTION_OUTSIDE = 4
const ACTION_POINTER_DOWN = 5
const ACTION_POINTER_UP = 6
const ACTION_POINTER_INDEX_MASK = 0x0000ff00
const ACTION_POINTER_INDEX_SHIFT = 8

@export
var _action: int
@export
var _events: Array[InputEvent]

func get_action() -> int:
	return _action


func get_action_index() -> int:
	return (_action & ACTION_POINTER_INDEX_MASK) >> ACTION_POINTER_INDEX_SHIFT


func get_action_masked() -> int:
	return _action & ACTION_MASK


func get_x(pointer_index: int) -> float:
	return _events[pointer_index].position.x


func get_y(pointer_index: int) -> float:
	return _events[pointer_index].position.y


func get_pointer_count() -> int:
	return _events.size()
