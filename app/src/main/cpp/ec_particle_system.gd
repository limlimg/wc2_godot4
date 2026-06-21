extends Node2D

const _ecEmitterAttr = preload("res://app/src/main/cpp/ec_emitter_attr.gd")
const _ecTextureResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_texture_res_assets.gd")
const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")

static var rng := RandomNumberGenerator.new()

@export
var emitter_attr: _ecEmitterAttr:
	set(value):
		if value != emitter_attr:
			if emitter_attr != null:
				emitter_attr.changed.disconnect(_on_emitter_attr_changed)
			emitter_attr = value
			if emitter_attr != null:
				_on_emitter_attr_changed()
				emitter_attr.changed.connect(_on_emitter_attr_changed)
			else:
				var curve := Curve.new()
				_speed_shift_curve = curve
				_gravity_shift_curve = curve
				_rot_shift_curve = curve
				_emission_curve = curve


@export
var texture_res: _ecTextureResAssets

var _live := false:
	set(value):
		_live = value
		set_process(value)


var _speed_shift_curve: Curve
var _gravity_shift_curve: Curve
var _rot_shift_curve: Curve
var _emission_curve: Curve
var _emitted_time := 0.0
var _emitted_quantity := 0
var _last_position: Vector2
var _fire_at_angle: float

signal stopped

func _ready() -> void:
	_emitted_time = 0.0
	_emitted_quantity = 0
	_live = false


func fire_at(x: float, y: float, angle: float) -> void:
	_fire_at_angle = angle
	stop(false)
	move_to(x, y, false)
	fire()


func fire() -> void:
	_emitted_time = 0.0
	_emitted_quantity = 0
	_live = true


func stop(stop_existing: bool) -> void:
	_live = false
	if stop_existing:
		for i in $LiveParticles.get_children():
			$LiveParticles.remove_child(i)
			i.queue_free()
	_on_stopped()


func _on_stopped() -> void:
	if not is_live():
		stopped.emit()


func is_live() -> bool:
	return $LiveParticles.get_child_count() > 0 or _live


func move_to(x: float, y: float, move_existing: bool) -> void:
	var target := Vector2(x, y) + emitter_attr.offset
	if not move_existing:
		for i in $LiveParticles.get_children():
			i.position -= target - position
	if move_existing or _live:
		_last_position = position
	else:
		_last_position = target
	position = target


func _process(delta: float) -> void:
	if emitter_attr == null:
		return
	var emitter_life := emitter_attr.emitter_life
	_emitted_time += delta
	if _emitted_time >= emitter_life:
		if emitter_attr.settings_mode != 0:
			_emitted_time = emitter_life
			_live = false
	var target_quantity := _sample_curve_extended(_emission_curve, _emitted_time)
	while _emitted_quantity < target_quantity - 1:
		var particle := $Prototype/ecParticle.duplicate()
		particle.lifespam = rng.randf_range(emitter_attr.particle_life_min, emitter_attr.particle_life_max)
		var texture = texture_res.get_res().get_image(emitter_attr.image_file)
		var texture_scale := Vector2.ONE
		if texture != null:
			particle.texture = _ecImageTexture.from_ec_image_attr(texture)
			texture_scale = Vector2(emitter_attr.image_width, emitter_attr.image_height) / particle.texture.get_size()
			particle.material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD if emitter_attr.image_blend == 1 else CanvasItemMaterial.BLEND_MODE_MIX
		match emitter_attr.settings_type:
			0:
				particle.offset.x = rng.randf_range(_last_position.x - position.x, 0.0) + rng.randf_range(-2.0, 2.0)
				particle.offset.y = rng.randf_range(_last_position.y - position.y, 0.0) + rng.randf_range(-2.0, 2.0)
			2:
				particle.offset.x = rng.randf_range(_last_position.x - position.x, 0.0) + rng.randf_range(-0.5, 0.5) * emitter_attr.settings_param_1
				particle.offset.y = rng.randf_range(_last_position.y - position.y, 0.0) + rng.randf_range(-0.5, 0.5) * emitter_attr.settings_param_2
		var speed_angle := _fire_at_angle + rng.randf_range(emitter_attr.angle_min, emitter_attr.angle_max)
		particle.speed = Vector2.from_angle(speed_angle) * rng.randf_range(emitter_attr.speed_min, emitter_attr.speed_max)
		particle.speed_shift_curve = _speed_shift_curve
		particle.gravity = rng.randf_range(emitter_attr.gravity_min, emitter_attr.gravity_max)
		particle.gravity_shift_curve = _gravity_shift_curve
		particle.initial_scale = texture_scale * rng.randf_range(emitter_attr.scale_min, emitter_attr.scale_max)
		particle.scale_curve = emitter_attr.life_track_scale
		if emitter_attr.rot_angle_type == 1.0:
			particle.initial_rot_angle = _fire_at_angle + speed_angle
		else:
			particle.initial_rot_angle = _fire_at_angle + rng.randf_range(emitter_attr.rot_angle_min, emitter_attr.rot_angle_max)
		particle.rot_speed = rng.randf_range(emitter_attr.rot_speed_min, emitter_attr.rot_speed_max)
		particle.rot_shift_curve = _rot_shift_curve
		particle.color = emitter_attr.color_range.sample(rng.randf_range(0.0, 1.0))
		particle.color_gradient = emitter_attr.life_track_color
		$LiveParticles.add_child(particle)
		particle.stopped.connect(_on_stopped)
		_emitted_quantity += 1


func _on_emitter_attr_changed() -> void:
	var speed_curve :=emitter_attr.life_track_speed
	_speed_shift_curve = _integrate_curve(speed_curve)
	var gravity_v_curve := _integrate_curve(emitter_attr.life_track_gravity)
	var gravity_kv_curve := Curve.new()
	gravity_kv_curve.min_domain = gravity_v_curve.min_domain
	gravity_kv_curve.max_domain = gravity_v_curve.max_domain
	for i in gravity_v_curve.point_count:
		var p0 := speed_curve.get_point_position(i)
		var p1 := gravity_v_curve.get_point_position(i)
		var dy0_l := speed_curve.get_point_left_tangent(i)
		var dy1_l := gravity_v_curve.get_point_left_tangent(i)
		var dy0_r := speed_curve.get_point_right_tangent(i)
		var dy1_r := gravity_v_curve.get_point_right_tangent(i)
		var y := p0.y * p1.y
		if y < gravity_kv_curve.min_value:
			gravity_kv_curve.min_value = y
		if y > gravity_kv_curve.max_value:
			gravity_kv_curve.max_value = y
		gravity_kv_curve.add_point(Vector2(p0.x, y), dy0_l * p1.y + p0.y * dy1_l, dy0_r * p1.y + p0.y * dy1_r)
	_gravity_shift_curve = _integrate_curve(gravity_kv_curve)
	_rot_shift_curve = _integrate_curve(emitter_attr.life_track_rot_speed)
	_emission_curve = _integrate_curve(emitter_attr.time_track)


static func _integrate_curve(curve: Curve) -> Curve:
	if curve == null:
		return null
	var integration := Curve.new()
	integration.min_domain = curve.min_domain
	integration.max_domain = curve.max_domain
	if curve.point_count == 0:
		return integration
	var p0 := curve.get_point_position(0)
	var y0 := 0.0
	for i in curve.point_count:
		var p1 := curve.get_point_position(i)
		if i > 0:
			var dx := p1.x - p0.x
			var dy0 := curve.get_point_right_tangent(i - 1)
			var dy1 := curve.get_point_left_tangent(i)
			y0 += ((p1.y + p0.y) / 2 - (dy1 - dy0) * dx / 12) * dx
		if y0 < integration.min_value:
			integration.min_value = y0
		if y0 > integration.max_value:
			integration.max_value = y0
		integration.add_point(Vector2(p1.x, y0), p1.y, p1.y)
	return integration


func _sample_curve_extended(curve: Curve, offset: float) -> float:
	var index := curve.point_count - 1
	var pm := curve.get_point_position(index)
	if offset > pm.x:
		return pm.y + curve.get_point_left_tangent(index) * (offset - pm.x)
	else:
		return curve.sample_baked(offset)
