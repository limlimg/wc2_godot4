@tool
extends "res://gui/gui_medal_button.gd"

const _WAR_MEDAL_NAME = [
	"soldiers",
	"airforce",
	"cannon",
	"panzer",
	"navy",
	"honor"
]


@export
var medal: int:
	set(value):
		if value != medal:
			medal = value
			set_level(level)


@export
var level: int:
	set = set_level


func _ready() -> void:
	super()
	_on_render()


func init() -> void:
	if not is_node_ready():
		return
	super()
	set_level(level)


func set_level(value: int) -> void:
	level = value
	var res := texture_res
	if res == null:
		res = s_texture_res
	if res != null:
		$Medal.texture = res.get_image("medal_{0}_{1}.png".format([_WAR_MEDAL_NAME[medal], level]))
		_on_render()
	else:
		$Medal.texture = null


func _on_render():
	super()
	if enable:
		if $TextureButton.button_pressed:
			$Medal.self_modulate = Color(Color8(0xD2, 0xD2, 0xD2), alpha)
		else:
			$Medal.self_modulate = Color(Color.WHITE, alpha)
