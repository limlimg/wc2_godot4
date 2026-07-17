extends GUIElement

## Common base class for GUIBattleItem and GUICountryItem.

@export
var texture_res: ecTextureRes:
	set(value):
		if value != texture_res:
			texture_res = value
			init()


@export
var button_texture: Texture2D:
	get():
		return $Control/ButtonImage.texture
	set(value):
		$Control/ButtonImage.texture = value


@export
var text_texture: Texture2D:
	get():
		return $Control/TextImage.texture
	set(value):
		$Control/TextImage.texture = value


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
		return not $Control/Button.disabled
	set(value):
		$Control/Button.disabled = not value


var selected: bool:
	set = set_selected


@onready var _stars: Array[Sprite2D] = [
	$Control/SmallRankStar,
	$Control/SmallRankStar2,
	$Control/SmallRankStar3,
	$Control/SmallRankStar4,
	$Control/SmallRankStar5
	]

var _down: bool

func _ready() -> void:
	init()
	_move_button()


func init() -> void:
	_on_render()


func _move_button() -> void:
	show_behind_parent = not selected
	var offset: float
	if selected:
		if ecGraphics.instance().content_scale_size_mode == 3:
			offset = selected_offset_ipad
		else:
			offset = selected_offset
	else:
		offset = 0.0
	$Control.position = Vector2(offset, 0.0)


func set_selected(value: bool) -> void:
	if value != selected:
		selected = value
		_move_button()
		_on_render()


func _on_button_button_down() -> void:
	_down = true
	_on_render()


func _on_button_button_up() -> void:
	_down = false
	_on_render()


func _on_button_pressed() -> void:
	CSoundBox.get_instance().play_se("btn.wav")


func _on_render() -> void:
	var color := Color.from_rgba8(0xD2, 0xD2, 0xD2)
	if not locked and not _down:
		color = Color.WHITE
	$Control/ButtonImage.self_modulate = color
	$Control/TextImage.self_modulate = color
	if selected:
		$Control/ButtonImage.position.y = -size.y * 0.075
		$Control/ButtonImage.scale = Vector2(1.15, 1.15)
	else:
		$Control/ButtonImage.position.y = 0.0
		$Control/ButtonImage.scale = Vector2.ONE
	if not locked:
		if selected:
			$Control/TextImage.scale = Vector2(1.15, 1.15)
		else:
			$Control/TextImage.scale = Vector2.ONE
		$Control/TextImage.visible = true
		$Control/MarkLocked.visible = false
		var star_pos: Array[Vector2]
		if ecGraphics.instance().content_scale_size_mode == 3:
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
		for i in _stars.size():
			if i < star:
				_stars[i].position = star_pos[i]
				_stars[i].visible = true
			else:
				_stars[i].visible = false
	else:
		$Control/TextImage.visible = false
		$Control/MarkLocked.visible = true
		$Control/SmallRankStar.visible = false
		$Control/SmallRankStar2.visible = false
		$Control/SmallRankStar3.visible = false
		$Control/SmallRankStar4.visible = false
		$Control/SmallRankStar5.visible = false


func _get_minimum_size() -> Vector2:
	if ecGraphics.instance().content_scale_size_mode == 3:
		return Vector2(0.0, 80.0)
	else:
		return Vector2(0.0, 40.0)
