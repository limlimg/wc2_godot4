extends Node2D

@export
var texture: Texture2D

@export
var speed: Vector2

@export
var speed_shift_curve := Curve.new()

@export
var gravity: float

@export
var gravity_shift_curve := Curve.new()

@export
var scale_curve := Curve.new()

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
	if _life + delta > lifespam:
		get_parent().remove_child(self)
		queue_free()
		return
	var t0 := _life / lifespam
	var t1 := (_life + delta) / lifespam
	position += speed * (speed_shift_curve.sample_baked(t1) - speed_shift_curve.sample_baked(t0))
	position.y += gravity * (gravity_shift_curve.sample_baked(t1) - gravity_shift_curve.sample_baked(t0))
	rotation += rot_speed * (rot_shift_curve.sample_baked(t1) - rot_shift_curve.sample_baked(t0))
	_life += delta
	queue_redraw()


func _draw() -> void:
	if texture == null:
		return
	var life_ratio := _life / lifespam
	var scale_t := scale_curve.sample_baked(life_ratio)
	var src_rect := Rect2(Vector2.ZERO, texture.get_size())
	var rect := Rect2(Vector2.ZERO, src_rect.size * scale_t)
	var modulate_t := color * color_gradient.sample(life_ratio)
	draw_texture_rect_region(texture, rect, src_rect, modulate_t)
