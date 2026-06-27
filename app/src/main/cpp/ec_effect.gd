extends Node2D

const _ecEffectRes = preload("res://app/src/main/cpp/ec_effect_res.gd")

@export
var effect_res: _ecEffectRes:
	set(value):
		if value != effect_res:
			if effect_res != null:
				effect_res.changed.disconnect(init)
			effect_res = value
			if is_node_ready():
				init()
			if value != null:
				value.changed.connect(init)


signal stopped

func _ready() -> void:
	init()


func init() -> void:
	for i in $LiveParticles.get_children():
		$LiveParticles.remove_child(i)
		i.queue_free()
	if effect_res != null and effect_res.texture_res != null:
		for i in effect_res.emitter:
			var particle := $Prototype/ecParticleSystem.duplicate()
			particle.emitter_attr = i
			particle.texture_res = effect_res.texture_res
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
