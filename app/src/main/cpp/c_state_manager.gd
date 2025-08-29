
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

static var _instance := new()

var _states: Array[PackedScene]
var _cur_state: String

static func instance() -> _CStateManager:
	return _instance


func init() -> void:
	# nothing to do
	pass


func term() -> void:
	var placeholder := Node.new()
	var pack := PackedScene.new()
	pack.pack(placeholder)
	(Engine.get_main_loop() as SceneTree).change_scene_to_packed(pack)


func update(delta: float) -> void:
	# State transition is invoked by call_defered in set_cur_state
	# State functions are invoked by Node callbacks instead
	pass


func render() -> void:
	# State functions are invoked by Node callbacks instead
	pass


func touch_begin(x: float, y: float, index: float) -> void:
	# State functions are invoked by Node callbacks instead
	pass


func touch_move(x: float, y: float, index: float) -> void:
	# State functions are invoked by Node callbacks instead
	pass


func touch_end(x: float, y: float, index: float) -> void:
	# State functions are invoked by Node callbacks instead
	pass


func back_pressed() -> void:
	# State functions are invoked by Node callbacks instead
	pass


func key_down(key: Key) -> void:
	# State functions are invoked by Node callbacks instead
	pass


func scroll_wheel(x_value: float, y_value: float, _a3: float) -> void:
	# State functions are invoked by Node callbacks instead
	pass


func enter_background() -> void:
	# State functions are invoked by Node callbacks instead
	pass


func enter_foreground() -> void:
	# State functions are invoked by Node callbacks instead
	pass


# Used to cache the coressponding PackedScene in ResourceLoader
func register_state(path: String) -> void:
	var state := load(path) as PackedScene
	if state == null:
		push_error("Failed to load {0}".format([path]))
		return
	_states.append(state)


func set_cur_state(path: String) -> void:
	if _cur_state != path:
		_cur_state = path
		(func ():
			var err: Error =(Engine.get_main_loop() as SceneTree).change_scene_to_file(path)
			if err != OK:
				push_error("{0}: Failed to change state to {1}".format([error_string(err), path]))
		).call_deferred()


## While in the original game code it is possible get arbitrary states, here
## only the current state can be got.
func get_cur_state() -> Node:
	return (Engine.get_main_loop() as SceneTree).current_scene
