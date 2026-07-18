extends GUIElement

@export
var asset: AssetRegistry

var _cmds: TutorialCmdList
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
	_cmds = load(EC2dAppDelegate.get_asset_path(asset.get_resolved_name(), ""))


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
			if ecGraphics.instance().content_scale_size_mode == 3:
				AppDelegate.g_Scene.move_camera_to_area(cmd.id)
			else:
				AppDelegate.g_Scene.move_camera_center_to_area(cmd.id)
			var waiting_cmd := _current_cmd
			await AppDelegate.g_Scene.move_camera_completed
			_skip_cmd(waiting_cmd)
		"finger at":
			$Hand.visible = true
			$Hand.position = Vector2(cmd.x, cmd.y)
			_exe_cmd(index + 1)
		"finger to":
			_tween = create_tween()
			_tween.tween_property($Hand, "position", Vector2(cmd.x, cmd.y), 1.0)
			_tween.tween_callback(_skip_cmd.bind(_current_cmd))
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
			await $Button.pressed
			_exe_cmd(index + 1)
		"show image":
			$Tutorials.texture = ecGraphics.instance().load_texture("tutorails{0}.webp".format([cmd.id]))
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
	CSoundBox.get_instance().play_se("btn.wav")


func _skip_cmd(skip_cmd: int) -> void:
	if _current_cmd == skip_cmd:
		_exe_cmd(_current_cmd + 1)
