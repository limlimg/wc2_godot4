extends "res://app/src/main/cpp/gui_element.gd"

@export
var horizontal: bool:
	get():
		return $HSlider.visible
	set(value):
		$HSlider.visible = value
		$VSlider.visible = not value


@export
var max_value: float:
	get():
		return $HSlider.max_value if horizontal else $VSlider.max_value
	set(value):
		var f: float
		f = $VSlider.value * (value / $VSlider.max_value)
		$VSlider.max_value = value
		$VSlider.set_value_no_signal(f)
		f = $HSlider.value * (value / $HSlider.max_value)
		$HSlider.max_value = value
		$VSlider.set_value_no_signal(f)


@export
var value: float:
	get = get_scroll_pos,
	set = set_scroll_pos


@export
var grabber_size: Vector2:
	get():
		return $Grabber.size
	set(value):
		if value != $Grabber.size:
			$Grabber.size = value
			_on_render()


@export_group("Textures", "texture_")
@export
var texture_normal: Texture2D:
	get():
		return $Grabber.texture_normal
	set(value):
		$Grabber.texture_normal = value


@export
var texture_pressed: Texture2D:
	get():
		return $Grabber.texture_pressed
	set(value):
		$Grabber.texture_pressed = value


signal value_changed(value: float)

func init(rect: Rect2, normal_image_name: StringName,
		pressed_image_name: StringName, grabber_size_w: int,
		grabber_size_h: int, default_value: int, set_max_value: int,
		is_horizontal: bool) -> void:
	position = rect.position
	size = rect.size
	texture_normal = _s_texture_res.get_image(normal_image_name)
	texture_pressed = _s_texture_res.get_image(pressed_image_name)
	grabber_size = Vector2(grabber_size_w, grabber_size_h)
	max_value = set_max_value
	horizontal = is_horizontal
	set_scroll_pos(default_value)


func get_scroll_pos() -> float:
	return $HSlider.value if horizontal else $VSlider.value


func set_scroll_pos(pos: float) -> void:
	if horizontal:
		$HSlider.set_value_no_signal(pos)
	else:
		$VSlider.set_value_no_signal(pos)


func _ready() -> void:
	_on_render()


func _on_render() -> void:
	var range_size := size - grabber_size
	var proportion := Vector2($HSlider.value / $HSlider.max_value, $VSlider.value / $VSlider.max_value)
	$Grabber.position = range_size * proportion


# inspector connection cannot bind and unbind arguments at the same time
func _on_drag_ended() -> void:
	$Grabber.set_pressed_no_signal(false)


func _on_value_changed(_value: float) -> void:
	_on_render()
	value_changed.emit(_value)
