extends "res://app/src/main/cpp/gui_radio_button.gd"

const _ecTextureResAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_texture_res_assets.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")


@export
var empty := true:
	set(value):
		if value != empty:
			empty = value
			_set_info()

@export
var country_res: _ecTextureResAssets:
	set(value):
		if value != country_res:
			country_res = value
			_set_info()


@export
var country: String:
	set(value):
		if value != country:
			country = value
			_set_info()


@export
var game_mode: int:
	set(value):
		if value != game_mode:
			game_mode = value
			_set_info()


@export
var campaign: int:
	set(value):
		if value != campaign:
			campaign = value
			_set_info()


@export
var battle: int:
	set(value):
		if value != battle:
			battle = value
			_set_info()


@export
var year: int:
	set(value):
		if value != year:
			year = value
			_set_info()


@export
var month: int:
	set(value):
		if value != month:
			month = value
			_set_info()


@export
var day: int:
	set(value):
		if value != day:
			day = value
			_set_info()


@export
var hour: int:
	set(value):
		if value != hour:
			hour = value
			_set_info()


@export
var minute: int:
	set(value):
		if value != minute:
			minute = value
			_set_info()


func _ready() -> void:
	super()
	init()
	_set_info()


func init() -> void:
	if _native.g_localizable_strings.get_string("language") != "en":
		if _ecGraphics.instance().content_scale_size_mode == 3:
			$Name.position.y = -4.0
		else:
			$Name.position.y = -2.0


func _set_info() -> void:
	if not empty:
		if country_res != null:
			var flag_attr := country_res.get_res().get_image("flag_{0}.png".format([country]))
			$Flag/TextureRect.texture = _ecImageTexture.from_ec_image_attr(flag_attr)
		$Time/ecText.text = _make_time_string()
		if game_mode != 2:
			var campaign_key := "alliance name {0}".format([campaign + 1])
			var campaign_name := _native.g_string_table.get_string(campaign_key)
			$Name/ecText.text = "{0} {1}".format([campaign_name, battle + 1])
		else:
			$Name/ecText.text = "conquest name {0}".format([battle + 1])
	else:
		$Flag/TextureRect.texture = null
		$Time/ecText.text = ""
		$Name/ecText.text = ""

func _make_time_string() -> String:
	return "%02d:%02d %04d/%02d/%02d"%[hour, minute, year, month, day]


func _on_render():
	if selected:
		$Glow.self_modulate = Color(Color.WHITE, alpha)
		$Glow.show()
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("selected_flash")
	else:
		$Glow.hide()
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop()
		var color: Color
		if not enable:
			color = Color(Color8(0x78, 0x78, 0x78), alpha)
		else:
			if $TextureButton.button_pressed:
				color = Color(Color8(0xD2, 0xD2, 0xD2), alpha)
			else:
				color = Color.WHITE
		$TextureButton.self_modulate = color
