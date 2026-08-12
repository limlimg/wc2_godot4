@tool
class_name GUISaveItem
extends GUIRadioButton

@export
var empty := true:
	set(value):
		if value != empty:
			empty = value
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


var _flash_a: float

func _ready() -> void:
	super()
	_set_info()


func init() -> void:
	if not is_node_ready():
		return
	super()
	if Engine.is_editor_hint():
		return
	_flash_a = 1.0
	if g_LocalizableStrings.get_string("language") != "en":
		if ecGraphics.instance().content_scale_size_mode == 3:
			$Name.position.y += -4.0
		else:
			$Name.position.y += -2.0


func _set_info() -> void:
	if not empty:
		var res := texture_res
		if res == null:
			res = s_texture_res
		if res != null:
			$Flag/TextureRect.texture = res.get_image("flag_{0}.png".format([country]))
		$Time/ecText.text = _make_time_string()
		if game_mode != 2:
			var campaign_key := "alliance name {0}".format([campaign + 1])
			var campaign_name = g_StringTable.get_string(campaign_key)
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
	else:
		$Glow.hide()
		var color: Color
		if not enable:
			color = Color(Color8(0x78, 0x78, 0x78), alpha)
		else:
			if $TextureButton.button_pressed:
				color = Color(Color8(0xD2, 0xD2, 0xD2), alpha)
			else:
				color = Color.WHITE
		$TextureButton.self_modulate = color


func _process(delta: float) -> void:
	if selected:
			_flash_a -= 0.4 * delta
			if _flash_a < 0.6:
				_flash_a += 0.4
			$TextureButton.self_modulate = Color.from_rgba8(200, 255, 200) * (0.8 + absf(_flash_a - 0.8))
	else:
		$TextureButton.self_modulate = Color.WHITE
