extends "res://core/java/android/opengl/gl_surface_view.gd"

const _ecRenderer = preload("res://app/src/main/java/com/easytech/wc2/ec_renderer.gd")

var _m_renderer: _ecRenderer

func _init():
	_m_renderer = _ecRenderer.new()
	set_renderer(Callable(_m_renderer, &"on_surface_created"), Callable(_m_renderer, &"on_surface_changed"), Callable(_m_renderer, &"on_draw_frame"))
	_surface_created.emit() # added for immediate initialization


func _on_touch_event(event: _MotionEvent) -> bool:
	var action := event.get_action_masked()
	if action == _MotionEvent.ACTION_DOWN:
		(func(): 
			_m_renderer.on_touch(0, event.get_x(0), event.get_y(0), 1)
		).call_deferred()
	elif action == _MotionEvent.ACTION_UP:
		(func(): 
			_m_renderer.on_touch(1, event.get_x(0), event.get_y(0), 0)
		).call_deferred()
	elif action == _MotionEvent.ACTION_MOVE:
		for i in event.get_pointer_count():
			(func(): 
				_m_renderer.on_touch(2, event.get_x(i), event.get_y(i), 0)
			).call_deferred()
	# The original code creates runnables for the following cases but doesn't actually run them.
	#elif action == _MotionEvent.ACTION_OUTSIDE:
		#(func(): 
			#_m_renderer.on_touch(1, event.get_x(0), event.get_y(0), 0)
		#)
	#elif action == _MotionEvent.ACTION_POINTER_DOWN:
		#var index := event.get_action_index()
		#(func(): 
			#_m_renderer.on_touch(0, event.get_x(index), event.get_y(index), 0)
		#)
	#elif action == _MotionEvent.ACTION_POINTER_UP:
		#var index := event.get_action_index()
		#(func(): 
			#_m_renderer.on_touch(1, event.get_x(index), event.get_y(index), 0)
		#)
	return true
