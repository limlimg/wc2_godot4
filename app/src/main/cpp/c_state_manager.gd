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


func _enter_tree() -> void:
	_cur_state = get_tree().current_scene


func _process(delta: float) -> void:
	update(delta)


func init() -> void:
	# nothing to do
	pass


func term() -> void:
	_cur_state = null
	# self already out of tree, so cannot call get_tree() here
	Engine.get_main_loop().unload_current_scene()


func update(_delta: float) -> void:
	_cur_state_path = _next_state_path
	_cur_state = get_tree().current_scene


func render() -> void:
	# nothing to do
	pass


func touch_begin(_x: float, _y: float, _index: float) -> void:
	# nothing to do
	pass


func touch_move(_x: float, _y: float, _index: float) -> void:
	# nothing to do
	pass


func touch_end(_x: float, _y: float, _index: float) -> void:
	# nothing to do
	pass


func back_pressed() -> bool:
	# nothing to do
	return false


func key_down(_key: Key) -> void:
	# nothing to do
	pass


func scroll_wheel(_x_value: float, _y_value: float, _a3: float) -> void:
	# nothing to do
	pass


func enter_background() -> void:
	# nothing to do
	pass


func enter_foreground() -> void:
	# nothing to do
	pass


func register_state(_path: String) -> void:
	# nothing to do
	pass


func set_cur_state(path: String) -> void:
	if path != _cur_state_path and path != _next_state_path:
		get_tree().change_scene_to_file(path)
		_next_state_path = path
		_cur_state = null


## While in the original game code it is possible get arbitrary states, here
## only the current state can be got.
func get_cur_state() -> Node:
	return _cur_state
