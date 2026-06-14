class_name ecEmitterAttr
extends Resource

@export
var offset: Vector2

@export
var settings_mode: int

@export
var settings_type: int

@export
var settings_param_1: float

@export
var settings_param_2: float

@export
var rot_angle_type: float

@export
var rot_angle_min: float

@export
var rot_angle_max: float

@export
var image_file: String

@export
var image_blend: int

@export
var image_width: float

@export
var image_height: float

@export
var emitter_life: float

@export
var particle_life_min: float

@export
var particle_life_max: float

@export
var angle_min: float

@export
var angle_max: float

@export
var speed_min: float

@export
var speed_max: float

@export
var gravity_min: float

@export
var gravity_max: float

@export
var scale_min: float

@export
var scale_max: float

@export
var rot_speed_min: float

@export
var rot_speed_max: float

@export
var color_min: Color

@export
var color_max: Color

@export
var time_track_integerated := Curve.new()

@export
var life_track_speed := Curve.new()

@export
var life_track_gravity := Curve.new()

@export
var life_track_scale := Curve.new()

@export
var life_track_rot_speed := Curve.new()

@export
var life_track_color := Gradient.new()
