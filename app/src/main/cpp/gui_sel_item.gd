extends "res://app/src/main/cpp/gui_element.gd"

## Common base class for GUIBattleItem and GUICountryItem.

const _ecImageTextureAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture_assets.gd")
const _ecImage = preload("res://app/src/main/cpp/ec_image.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")

const _RESOURCE_PATH = "res://app/src/main/cpp/scene_system_resource/selbattle_res/"

@export
var button_texture: Texture2D:
	set(value):
		if value != button_texture:
			button_texture = value
			init()


@export
var text_texture: Texture2D:
	set(value):
		if value != text_texture:
			text_texture = value
			init()


@export
var locked: bool:
	set(value):
		if value != locked:
			locked = value
			init()


@export
var star: int:
	set(value):
		if value != star:
			star = value
			init()


@export
var selected_offset_ipad: float:
	set(value):
		if value != selected_offset_ipad:
			selected_offset_ipad = value
			_move_button()


@export
var selected_offset: float:
	set(value):
		if value != selected_offset:
			selected_offset = value
			_move_button()


var enable: bool:
	get():
		return not $MarginContainer/Control/Button.disabled
	set(value):
		$MarginContainer/Control/Button.disabled = not value


var selected: bool:
	set = set_selected


var _button_image: _ecImage
var _text_image: _ecImage
var _star_image: _ecImage
var _down: bool

func _ready() -> void:
	init()
	_move_button()


func init() -> void:
	if button_texture != null:
		_button_image = _ecImage.new(button_texture, 0.0, 0.0, button_texture.get_width(), button_texture.get_height())
	else:
		_button_image = null
	if text_texture != null:
		_text_image = _ecImage.new(text_texture, 0.0, 0.0, text_texture.get_width(), text_texture.get_height())
	else:
		_text_image = null
	var res: _ecImageTextureAssets
	if locked:
		res = load(_RESOURCE_PATH + "mark_locked.png.tres")
		_star_image = _ecImage.new(res.get_image_attr())
	else:
		res = load(_RESOURCE_PATH + "small_rankstar.png.tres")
		_star_image = _ecImage.new(res.get_image_attr())
	$MarginContainer/Control/Button.queue_redraw()


func _move_button() -> void:
	show_behind_parent = not selected
	var offset := 0.0
	if selected:
		if _ecGraphics.instance().content_scale_size_mode == 3:
			offset = selected_offset_ipad
		else:
			offset = selected_offset
	$MarginContainer/Control/Button.position = Vector2(offset, 0.0)


func set_selected(value: bool) -> void:
	if value != selected:
		selected = value
		_move_button()
		$MarginContainer/Control/Button.queue_redraw()


func _on_button_button_down() -> void:
	_down = true
	$MarginContainer/Control/Button.queue_redraw()


func _on_button_button_up() -> void:
	_down = false
	$MarginContainer/Control/Button.queue_redraw()


func _on_button_pressed() -> void:
	_CSoundBox.get_instance().play_se("btn.wav")


func _on_render() -> void:
	if _button_image == null:
		return
	var graphics := _ecGraphics.instance()
	graphics.render_begin($MarginContainer/Control/Button)
	var color := Color(1.0, 0.824, 0.824, 0.816)
	if not locked and not _down:
		color = Color.WHITE
	_button_image.set_color(color, -1)
	if _text_image != null:
		_text_image.set_color(color, -1)
	if selected:
		_button_image.render_ex(0.0, -size.y * 0.075, 0.0, 1.15, 0.0)
		if _text_image != null and not locked:
			_text_image.render_ex(0.0, size.y * 0.5, 0.0, 1.15, 0.0)
	else:
		_button_image.render(0.0, 0.0)
		if _text_image != null and not locked:
			_text_image.render(0.0, size.y * 0.5)
	var star_pos: Array[Vector2]
	if graphics.content_scale_size_mode == 3:
		if locked:
			_star_image.render_ex(134.0, 44.0, 0.0, 0.8, 0.0)
		else:
			match star:
				1:
					star_pos = [Vector2(44.0, 66.0)]
				2:
					star_pos = [Vector2(32.0, 66.0), Vector2(56.0, 66.0)]
				3:
					star_pos = [Vector2(20.0, 66.0), Vector2(44.0, 66.0), Vector2(68.0, 66.0)]
				4:
					star_pos = [Vector2(32.0, 46.0), Vector2(32.0, 68.0), Vector2(56.0, 46.0), Vector2(56.0, 68.0)]
				5:
					star_pos = [Vector2(20.0, 46.0), Vector2(44.0, 46.0), Vector2(68.0, 46.0), Vector2(32.0, 68.0), Vector2(56.0, 68.0)]
	else:
		if locked:
			_star_image.render_ex(67.0, 22.0, 0.0, 0.8, 0.0)
		else:
			match star:
				1:
					star_pos = [Vector2(22.0, 33.0)]
				2:
					star_pos = [Vector2(16.0, 33.0), Vector2(28.0, 33.0)]
				3:
					star_pos = [Vector2(10.0, 33.0), Vector2(22.0, 33.0), Vector2(34.0, 33.0)]
				4:
					star_pos = [Vector2(16.0, 23.0), Vector2(16.0, 34.0), Vector2(28.0, 23.0), Vector2(28.0, 34.0)]
				5:
					star_pos = [Vector2(10.0, 23.0), Vector2(22.0, 23.0), Vector2(34.0, 23.0), Vector2(16.0, 34.0), Vector2(28.0, 34.0)]
	for p in star_pos:
		_star_image.render(p.x, p.y)
	graphics.render_end()
