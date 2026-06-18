extends Sprite2D

@export
var speed: Vector2

@export
var speed_shift_curve := Curve.new()

@export
var gravity: float

@export
var gravity_shift_curve := Curve.new()

@export
var initial_scale: Vector2

@export
var scale_curve := Curve.new()

@export
var initial_rot_angle: float

@export
var rot_speed: float

@export
var rot_shift_curve := Curve.new()

@export
var color: Color

@export
var color_gradient := Gradient.new()

@export
var lifespam: float

var _life := 0.0

func _ready() -> void:
	speed_shift_curve.bake()
	gravity_shift_curve.bake()
	scale_curve.bake()
	rot_shift_curve.bake()
	_life = 0.0


func _process(delta: float) -> void:
	_life += delta
	if _life > lifespam:
		get_parent().remove_child(self)
		queue_free()
		return
	var t1 := _life / lifespam
	position = speed * speed_shift_curve.sample_baked(t1)
	position.y += gravity * gravity_shift_curve.sample_baked(t1)
	rotation = initial_rot_angle + rot_speed * rot_shift_curve.sample_baked(t1)
	scale = initial_scale * scale_curve.sample_baked(t1)
	self_modulate = color * color_gradient.sample(t1)
