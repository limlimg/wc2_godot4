extends Node2D

const _ecEffectResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_effect_res_assets.gd")
const _ecTextureResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_texture_res_assets.gd")

@export
var effect_res: _ecEffectResAssets:
	set(value):
		if value != effect_res:
			effect_res = value
			if is_node_ready():
				init()


@export
var texture_res: _ecTextureResAssets:
	set(value):
		if value != texture_res:
			texture_res = value
			if is_node_ready():
				init()


signal stopped

func _ready() -> void:
	init()


func init() -> void:
	for i in $LiveParticles.get_children():
		$LiveParticles.remove_child(i)
		i.queue_free()
	if effect_res != null and texture_res != null:
		for i in effect_res.get_res().emitter:
			var particle := $Prototype/ecParticleSystem.duplicate()
			particle.emitter_attr = i
			particle.texture_res = texture_res
			$LiveParticles.add_child(particle)


func fire_at(x: float, y: float, angle: float) -> void:
	for i in $LiveParticles.get_children():
		i.fire_at(x, y, angle)


func fire() -> void:
	for i in $LiveParticles.get_children():
		i.fire()


func stop(stop_existing: bool) -> void:
	for i in $LiveParticles.get_children():
		i.stop(stop_existing)
	_on_stopped()


func _on_stopped() -> void:
	if not is_live():
		stopped.emit()


func is_live() -> bool:
	for i in $LiveParticles.get_children():
		if i.is_live():
			return true
	return false


func move_to(x: float, y: float, move_existing: bool) -> void:
	for i in $LiveParticles.get_children():
		i.move_to(x, y, move_existing)
