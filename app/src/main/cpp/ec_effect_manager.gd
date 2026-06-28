extends Node2D

const _ecEffectManager = preload("res://app/src/main/cpp/ec_effect_manager.gd")
const _ecEffect = preload("res://app/src/main/cpp/ec_effect.gd")
const _ecEffectRes = preload("res://app/src/main/cpp/ec_effect_res.gd")
const _AssetRegistry = preload("res://app/src/main/cpp/resources/assets/asset_registry.gd")

var _effects: Array[Node2D]

static func instance() -> _ecEffectManager:
	return (Engine.get_main_loop() as SceneTree).get_nodes_in_group("ecEffectManagerInstance")[-1]


func add_effect(file: String, auto_remove: bool) -> _ecEffect:
	var node := create_effect(file)
	_effects.append(node)
	if auto_remove:
		(func ():
			if node.is_live():
				node.stopped.connect(_remove.bind(node))
			else:
				_remove(node)
			).call_deferred()
	return node


func create_effect(file: String) -> _ecEffect:
	var node = $Prototype/ecEffect.create_instance()
	var res := _ecEffectRes.new()
	var asset := _AssetRegistry.new()
	asset.name = file
	res.asset = asset
	node.effect_res = res
	return node


func remove_all() -> void:
	for c in _effects:
		_remove(c)


func _remove(node: Node) -> void:
	_effects[_effects.find(node)] = _effects[-1]
	_effects.pop_back()
	remove_child(node)
	node.queue_free()
