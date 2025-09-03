extends Control

const _ViewTreeObserver = preload("res://core/java/android/view/view_tree_observer.gd")
const _MotionEvent = preload("res://core/java/android/view/motion_event.gd")

var _view_tree_observer: _ViewTreeObserver
var _motion_event := _MotionEvent.new()

signal _ready_deferred # This signal is supposed to trigger connections that have not made when ready is emitted, so ready.connect(CONNECT_DEFERRED) does not do the job.

func _on_touch_event(_event: _MotionEvent) -> bool:
	return false


func get_view_tree_observer() -> _ViewTreeObserver:
	if _view_tree_observer == null:
		_view_tree_observer = _ViewTreeObserver.new()
		var on_global_layout := Callable(_view_tree_observer, &"dispatch_on_global_layout")
		resized.connect(on_global_layout, CONNECT_DEFERRED)
		visibility_changed.connect(on_global_layout, CONNECT_DEFERRED)
		child_entered_tree.connect(on_global_layout.unbind(1), CONNECT_DEFERRED)
		child_exiting_tree.connect(on_global_layout.unbind(1), CONNECT_DEFERRED)
		child_order_changed.connect(on_global_layout, CONNECT_DEFERRED)
		_ready_deferred.connect(on_global_layout)
	return _view_tree_observer


func get_measured_width() -> int:
	return size.x as int


func get_measured_height() -> int:
	return size.y as int


func _ready() -> void:
	(func (): _ready_deferred.emit()).call_deferred()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			var pointer_count := _motion_event.get_pointer_count()
			if pointer_count == 0:
				_motion_event._action = _MotionEvent.ACTION_DOWN
			else:
				_motion_event._action = _MotionEvent.ACTION_POINTER_DOWN | ((pointer_count << _MotionEvent.ACTION_POINTER_INDEX_SHIFT) & _MotionEvent.ACTION_POINTER_INDEX_MASK)
			_motion_event._events.append(event)
			if _on_touch_event(_motion_event.duplicate()):
				accept_event()
		else:
			var pointer_index := _motion_event._events.find_custom(func (past_event: InputEvent): return past_event.index == event.index)
			if pointer_index == -1:
				push_warning("Inconsistent pointer in MotionEvent")
				return
			var pointer_count := _motion_event.get_pointer_count()
			if pointer_count == 1:
				_motion_event._action = _MotionEvent.ACTION_UP
			else:
				_motion_event._action = _MotionEvent.ACTION_POINTER_UP | ((pointer_index << _MotionEvent.ACTION_POINTER_INDEX_SHIFT) & _MotionEvent.ACTION_POINTER_INDEX_MASK)
			_motion_event._events[pointer_index] = event
			if _on_touch_event(_motion_event.duplicate()):
				accept_event()
			_motion_event._events[pointer_index] = _motion_event._events.back()
			_motion_event._events.pop_back()
	elif event is InputEventScreenDrag:
		var pointer_index := _motion_event._events.find_custom(func (past_event: InputEvent): return past_event.index == event.index)
		_motion_event._action = _MotionEvent.ACTION_MOVE
		_motion_event._events[pointer_index] = event
		if _on_touch_event(_motion_event.duplicate()):
			accept_event()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		var motion_event := _MotionEvent.new()
		motion_event._action = _MotionEvent.ACTION_OUTSIDE
		motion_event._events.append(event)
		if _on_touch_event(motion_event):
			get_viewport().set_input_as_handled()
