extends "res://app/src/main/cpp/gui_element.gd"

const _AssetRegistry = preload("res://app/src/main/cpp/resources/assets/asset_registry.gd")
const _TutorialCmdList = preload("res://app/src/main/cpp/resources/imported/tutorial_cmd_list.gd")
const _lib = preload("res://app/src/main/cpp/native-lib.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")

@export
var asset: _AssetRegistry

var _cmds: _TutorialCmdList
var _awaiting_input: bool
var _current_cmd: int
var _tween: Tween

signal select_area_executed(id: int)
signal unselect_area_executed
signal exit_executed

func _ready() -> void:
	init()


func init() -> void:
	_load_script()
	_exe_cmd(0)


func _load_script() -> void:
	_cmds = load(_lib.get_asset_path(asset.get_resolved_name(), ""))


func _release_script() -> void:
	_cmds = null


func _exe_cmd(index: int) -> void:
	_current_cmd = index
	if _tween != null:
		_tween.kill()
		_tween = null
	var cmd := _cmds.tutorial_script[index]
	match cmd.name:
		"sel area":
			select_area_executed.emit(cmd.id)
			_exe_cmd(index + 1)
		"unsel area":
			unselect_area_executed.emit()
			_exe_cmd(index + 1)
		"moveto area":
			if _ecGraphics.instance().content_scale_size_mode == 3:
				g_Scene.move_camera_to_area(cmd.id)
			else:
				g_Scene.move_camera_center_to_area(cmd.id)
			_awaiting_input = true
			await g_Scene.move_camera_completed
			_on_button_pressed()
		"finger at":
			$Hand.visible = true
			$Hand.position = Vector2(cmd.x, cmd.y)
			_exe_cmd(index + 1)
		"finger to":
			_tween = create_tween()
			_tween.tween_property($Hand, "position", Vector2(cmd.x, cmd.y), 1.0)
			_tween.tween_callback(_on_button_pressed)
			_awaiting_input = true
		"hide finger":
			$Hand.visible = false
			_exe_cmd(index + 1)
		"show text":
			if cmd.id > 0:
				_show_dlg_id(cmd.id)
			else:
				_show_dlg(cmd.string)
			_exe_cmd(index + 1)
		"draw rect":
			$drawRect.visible = true
			var panel: StyleBoxFlat = $drawRect.get_theme_stylebox(&"panel")
			panel.border_width_left = cmd.x as int
			panel.border_width_top = cmd.y as int
			panel.border_width_right = (size.x - cmd.x - cmd.w) as int
			panel.border_width_bottom = (size.y - cmd.y - cmd.h) as int
			_exe_cmd(index + 1)
		"clear rect":
			$drawRect.visible = false
			_exe_cmd(index + 1)
		"wait":
			_awaiting_input = true
		"show image":
			$Tutorials.texture = _ecGraphics.instance().load_texture("tutorails{0}.webp".format([cmd.id]))
			$Tutorials.position = Vector2(cmd.x, cmd.y)
			_exe_cmd(index + 1)
		"hide image":
			$Tutorials.texture = null
			_exe_cmd(index + 1)
		"exit":
			exit_executed.emit() # fade out 9


func _show_dlg_id(id: int) -> void:
	_show_dlg("tutorails {0}".format([id]))


func _show_dlg(dlg: String) -> void:
	$Dlg/Label.text = dlg
	show()
	_CSoundBox.get_instance().play_se("btn.wav")


func _on_button_pressed() -> void:
	if _awaiting_input:
		if g_Scene.move_camera_completed.is_connected(_on_button_pressed):
			g_Scene.move_camera_completed.disconnect(_on_button_pressed)
		_awaiting_input = false
		_exe_cmd(_current_cmd + 1)
