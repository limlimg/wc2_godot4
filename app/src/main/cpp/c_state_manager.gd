extends Node

## In the original game code, several states are defined as the primary
## controller of the game's behavour (i.e. rendering and responding to time
## passing and player input). They are called states because one state must be
## exited before another can be entered. CStateManager is a singleton class that
## manages such transition and invokes the functions of the active state. All
## the states are created and registered during initialization, but are empty
## until entered. During the registration, each state identifies itself with
## a enumerator of type EState.
## 
## In this Godot port, because of the primary role and the transition behavour,
## the states act as main scenes. State transition is done by changing the
## main scene in SceneTree and the functions are invoked by Node callbacks
## instead of this class. The states are only created when entered and are not
## registered in advance. Scene paths specify which state to create and enter,
## which means every scene can be used, not just subclasses of CBaseState.

const _CStateManager = preload("res://app/src/main/cpp/c_state_manager.gd")

var _cur_state: Node
var _cur_state_path: StringName
var _next_state_path: StringName

static func instance() -> _CStateManager:
	return CStateManager


func init() -> void:
	# nothing to do
	pass


func term() -> void:
	if _cur_state!= null and &"_on_exit" in _cur_state:
		_cur_state._on_exit()
	_cur_state = null
	# already out of tree, so cannot call get_tree() here
	Engine.get_main_loop().unload_current_scene()


func update(_delta: float) -> void:
	# Because scene change takes place at end of current frame,
	# state transition is done in two frames.
	var entering_state := _cur_state == null
	if entering_state:
		_cur_state = get_tree().current_scene
		if &"_on_enter" in _cur_state:
			_cur_state._on_enter()
	var exiting_state = _cur_state_path != _next_state_path
	if not exiting_state or entering_state:
		# To match original behavour, update current state once if it is changed
		# before _on_enter called.
		if _cur_state!= null and &"_update" in _cur_state:
			_cur_state._update(_delta)
	if exiting_state:
		if _cur_state!= null and &"_on_exit" in _cur_state:
			_cur_state._on_exit()
		var err: Error = get_tree().change_scene_to_file(_next_state_path)
		if err != OK:
			push_error("{0}: Failed to change state to {1}".format([error_string(err), _next_state_path]))
			_next_state_path = _cur_state_path
			if _cur_state!= null and &"_on_enter" in _cur_state:
				_cur_state._on_enter()
			return
		_cur_state_path = _next_state_path
		_cur_state = null
	pass


func render() -> void:
	if _cur_state!= null and &"_render" in _cur_state:
		_cur_state._render()


func touch_begin(x: float, y: float, index: float) -> void:
	if _cur_state!= null and &"_touch_begin" in _cur_state:
		_cur_state._touch_begin(x, y, index)


func touch_move(x: float, y: float, index: float) -> void:
	if _cur_state!= null and &"_touch_move" in _cur_state:
		_cur_state._touch_move(x, y, index)


func touch_end(x: float, y: float, index: float) -> void:
	if _cur_state!= null and &"_touch_move" in _cur_state:
		_cur_state._touch_move(x, y, index)


func back_pressed() -> bool:
	if _cur_state!= null and &"_back_pressed" in _cur_state:
		return _cur_state._back_pressed()
	return false


func key_down(key: Key) -> void:
	if _cur_state!= null and &"_key_down" in _cur_state:
		_cur_state._key_down(key)


func scroll_wheel(x_value: float, y_value: float, a3: float) -> void:
	if _cur_state!= null and &"_scroll_wheel" in _cur_state:
		_cur_state._scroll_wheel(x_value, y_value, a3)


func enter_background() -> void:
	if _cur_state!= null and &"_enter_background" in _cur_state:
		_cur_state._enter_background()


func enter_foreground() -> void:
	if _cur_state!= null and &"_enter_foreground" in _cur_state:
		_cur_state._enter_foreground()


func register_state(_path: String) -> void:
	# nothing to do
	pass


func set_cur_state(path: String) -> void:
	if path != _cur_state_path:
		_next_state_path = path


## While in the original game code it is possible get arbitrary states, here
## only the current state can be got.
func get_cur_state() -> Node:
	return _cur_state


func _enter_tree() -> void:
	_cur_state = get_tree().current_scene


func _process(delta: float) -> void:
	update(delta)
