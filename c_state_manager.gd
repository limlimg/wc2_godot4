class_name CStateManager
extends Control

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

var _states: Dictionary[int, CBaseState]
var _cur_state := EState.ESTATE_MAX as int
var _next_state := EState.ESTATE_MAX as int

static func instance() -> CStateManager:
	return (Engine.get_main_loop() as SceneTree).get_first_node_in_group(&"_ZN13CStateManager8InstancevE")


func init() -> void:
	_cur_state = EState.ESTATE_MAX
	_next_state = EState.ESTATE_MAX


func term() -> void:
	var _cur_state_node = _states.get(_cur_state)
	if _cur_state_node != null:
		_cur_state_node.hide()
	_states.clear()
	_cur_state = EState.ESTATE_MAX


func _process(delta: float) -> void:
	update(delta)


func update(_delta: float) -> void:
	if _next_state != _cur_state:
		var _cur_state_node = _states.get(_cur_state)
		if _cur_state_node != null:
			_cur_state_node.hide()
		_cur_state = _next_state
		_cur_state_node = _states.get(_next_state)
		if _cur_state_node != null:
			_cur_state_node.show()


func register_state(state: CBaseState) -> void:
	if state == null:
		return
	state.hide()
	add_child(state)
	_states[state.state] = state


func set_cur_state(state: int) -> void:
	_next_state = state


func get_state_ptr(state: int) -> Control:
	return _states.get(state)
