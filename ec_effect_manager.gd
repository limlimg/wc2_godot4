class_name ecEffectManager
extends Node2D

var _effects: Array[Node2D]
var _auto_remove_effects: Array[Node2D]

static func instance() -> ecEffectManager:
	return (Engine.get_main_loop() as SceneTree).get_first_node_in_group(&"_ZN15ecEffectManager8InstancevE")


func add_effect(file: String, auto_remove: bool) -> ecEffect:
	var node := create_effect(file)
	_effects.append(node)
	if auto_remove:
		_auto_remove_effects.append(node)
	return node


func create_effect(file: String) -> ecEffect:
	var node = $Prototype/ecEffect.create_instance()
	var res := ecEffectRes.new()
	var asset := AssetRegistry.new()
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
	node.queue_free()


func update(delta: float) -> void:
	var i := 0
	while i < _effects.size():
		var p := _effects[i]
		p.update(delta)
		if not p.is_live() and p in _auto_remove_effects:
			p.queue_free()
			_auto_remove_effects.erase(p)
			_effects.remove_at(i)
		else:
			i += 1
