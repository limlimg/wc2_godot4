extends Node2D

const _ecEffectManager = preload("res://app/src/main/cpp/ec_effect_manager.gd")
const _ecEffect = preload("res://app/src/main/cpp/ec_effect.gd")
const _ecEffectResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_effect_res_assets.gd")
const _AssetNamesContentSize = preload("res://app/src/main/cpp/scene_system_resource/asset_names_content_size.gd")

static func instance() -> _ecEffectManager:
	return (Engine.get_main_loop() as SceneTree).get_nodes_in_group("ecEffectManagerInstance")[-1]


func add_effect(file: String, auto_remove: bool) -> _ecEffect:
	var node := create_effect(file)
	$LiveEffect.add_child(node)
	if auto_remove:
		(func ():
			if node.is_live():
				node.stopped.connect(_remove.bind(node))
			else:
				_remove(node)
			).call_deferred()
	return node


func create_effect(file: String) -> _ecEffect:
	var node := $Prototype/ecEffect.duplicate()
	var res := _ecEffectResAssets.new()
	var asset_name := _AssetNamesContentSize.new()
	asset_name.name = file
	res.asset_name = asset_name
	node.effect_res = res
	return node


func remove_all() -> void:
	for c in $LiveEffect.get_children():
		_remove(c)


func _remove(effect: Node) -> void:
	$LiveEffect.remove_child(effect)
	effect.queue_free()
