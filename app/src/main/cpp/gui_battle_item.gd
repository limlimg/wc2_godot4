extends "res://app/src/main/cpp/gui_element.gd"

const _GUIBattleItem = preload("res://app/src/main/cpp/gui_battle_item.gd")
const _ecImageTextureAssets = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture_assets.gd")
const _ecImage = preload("res://app/src/main/cpp/ec_image.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")

const _MULTIPLAY_BATTLE = [
	"text_axis_01.png.tres",
	"text_axis_02.png.tres",
	"text_allies_02.png.tres",
	"text_axis_04.png.tres",
	"text_allies_07.png.tres",
	"text_axis_05.png.tres",
	"text_allies_09.png.tres",
	"text_axis_03.png.tres",
	"text_allies_04.png.tres",
	"text_allies_05.png.tres",
	"text_axis_06.png.tres",
	"text_allies_08.png.tres"
]
const _RESOURCE_PATH = "res://app/src/main/cpp/scene_system_resource/selbattle_res/"

@export
var campaign: int:
	set(value):
		if value != campaign:
			campaign = value
			init()

@export
var battle: int:
	set(value):
		if value != battle:
			battle = value
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

var _button_image: _ecImage
var _text_image: _ecImage
var _star_image: _ecImage
var _down: bool
var _selected: bool:
	set = set_selected

signal pressed(item: _GUIBattleItem)

func _ready() -> void:
	init()


func init() -> void:
	var res: _ecImageTextureAssets
	match campaign:
		0:
			res = load(_RESOURCE_PATH + "button_axis_%02d.png.tres"%(battle + 1))
			_button_image = _ecImage.new(res.get_image_attr())
			res = load(_RESOURCE_PATH + "text_axis_%02d.png.tres"%(battle + 1))
			_text_image = _ecImage.new(res.get_image_attr())
		1:
			res = load(_RESOURCE_PATH + "button_allies_%02d.png.tres"%(battle + 1))
			_button_image = _ecImage.new(res.get_image_attr())
			res = load(_RESOURCE_PATH + "text_allies_%02d.png.tres"%(battle + 1))
			_text_image = _ecImage.new(res.get_image_attr())
		2:
			res = load(_RESOURCE_PATH + "button_wto_%02d.png.tres"%(battle + 1))
			_button_image = _ecImage.new(res.get_image_attr())
			res = load(_RESOURCE_PATH + "text_wto_%02d.png.tres"%(battle + 1))
			_text_image = _ecImage.new(res.get_image_attr())
		3:
			res = load(_RESOURCE_PATH + "button_nato_%02d.png.tres"%(battle + 1))
			_button_image = _ecImage.new(res.get_image_attr())
			res = load(_RESOURCE_PATH + "text_nato_%02d.png.tres"%(battle + 1))
			_text_image = _ecImage.new(res.get_image_attr())
		4:
			res = load(_RESOURCE_PATH + "button_multiplay_%02d.png.tres"%(battle + 1))
			_button_image = _ecImage.new(res.get_image_attr())
			res = load(_RESOURCE_PATH + _MULTIPLAY_BATTLE[battle + 1])
			_text_image = _ecImage.new(res.get_image_attr())
	if locked:
		res = load(_RESOURCE_PATH + "mark_locked.png.tres")
		_star_image = _ecImage.new(res.get_image_attr())
	else:
		res = load(_RESOURCE_PATH + "small_rankstar.png.tres")
		_star_image = _ecImage.new(res.get_image_attr())
	queue_redraw()


func set_selected(value: bool) -> void:
	if value != _selected:
		_selected = value
		queue_redraw()


func _on_button_button_down() -> void:
	_down = true
	queue_redraw()


func _on_button_button_up() -> void:
	_down = false
	queue_redraw()


func _on_button_pressed() -> void:
	_CSoundBox.get_instance().play_se("btn.wav")
	pressed.emit(self)


func _draw() -> void:
	if _button_image == null:
		return
	var graphics := _ecGraphics.instance()
	graphics.render_begin(self)
	var color := Color(1.0, 0.824, 0.824, 0.816)
	if not locked and not _down:
		color = Color.WHITE
	_button_image.set_color(color, -1)
	if _text_image != null:
		_text_image.set_color(color, -1)
	if _selected:
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
