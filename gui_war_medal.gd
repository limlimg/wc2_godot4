@tool
extends "res://gui_medal_button.gd"

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
	init()
	_on_render()


func _on_asset_changed() -> void:
	super()
	init()


func init() -> void:
	set_level(level)


func set_level(value: int) -> void:
	level = value
	if texture_res != null:
		$Medal.texture = texture_res.get_image("medal_{0}_{1}.png".format([_WAR_MEDAL_NAME[medal], level]))
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
