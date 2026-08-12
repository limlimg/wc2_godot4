extends GUIElement

@export
var asset: AssetRegistry

var _move_hand_timer: float
var _cmds: TutorialCmdList
var _current_cmd: int
var _executing_cmd: bool
var _tween: Tween

func init() -> void:
	if not is_node_ready():
		return
	super()
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
		&"sel area":
			CStateManager.instance().get_state_ptr(EState.GAME).select_area(cmd.id)
			_executing_cmd = false
		&"unsel area":
			CStateManager.instance().get_state_ptr(EState.GAME).unselect_area()
			_executing_cmd = false
		&"moveto area":
			if ecGraphics.instance().content_scale_size_mode == 3:
				g_Scene.move_camera_to_area(cmd.id)
			else:
				g_Scene.move_camera_center_to_area(cmd.id)
			_executing_cmd = true
		&"finger at":
			$Hand.visible = true
			$Hand.position = Vector2(cmd.x, cmd.y)
			_executing_cmd = false
		&"finger to":
			if not Rect2(-1.0, -1.0, 2.0, 2.0).has_point($Hand.position - Vector2(cmd.x, cmd.y)):
				_move_hand_timer = 1.0
			else:
				_move_hand_timer = 0.0
			_executing_cmd = true
		&"hide finger":
			$Hand.visible = false
			_executing_cmd = false
		&"show text":
			if cmd.id > 0:
				_show_dlg_id(cmd.id)
			else:
				_show_dlg(cmd.string)
			_executing_cmd = false
		&"draw rect":
			$drawRect.visible = true
			var panel: StyleBoxFlat = $drawRect.get_theme_stylebox(&"panel")
			panel.border_width_left = cmd.x as int
			panel.border_width_top = cmd.y as int
			panel.border_width_right = (size.x - cmd.x - cmd.w) as int
			panel.border_width_bottom = (size.y - cmd.y - cmd.h) as int
			_executing_cmd = false
		&"clear rect":
			$drawRect.visible = false
			_executing_cmd = false
		&"wait":
			_executing_cmd = true
		&"show image":
			var image := ecImageAttr.new()
			image.texture = ecGraphics.instance().load_texture("tutorails{0}.webp".format([cmd.id]))
			image.region = Rect2(0.0, 0.0, cmd.w, cmd.h)
			$Tutorials.texture = image
			$Tutorials.position = Vector2(cmd.x, cmd.y)
			_executing_cmd = false
		&"hide image":
			$Tutorials.texture = null
			_executing_cmd = false
		&"exit":
			GUIManager.instance().fade_out(9, null)
			_executing_cmd = true


func _show_dlg_id(id: int) -> void:
	_show_dlg("tutorails {0}".format([id]))


func _show_dlg(dlg: String) -> void:
	$Dlg/Font8/Label.text = dlg
	show()
	CSoundBox.get_instance().play_se("btn.wav")


func _process(delta: float) -> void:
	if _current_cmd >= _cmds.tutorial_script.size():
		return
	if not _executing_cmd:
		_exe_cmd(_current_cmd)
		while not _executing_cmd:
			_current_cmd += 1
			_exe_cmd(_current_cmd)
	else:
		var cmd := _cmds.tutorial_script[_current_cmd]
		match cmd.name:
			&"moveto area":
				if not g_Scene.is_moving():
					_executing_cmd = false
					_current_cmd += 1
			&"finger to":
				var dest := Vector2(cmd.x, cmd.y)
				if _move_hand_timer > delta:
					$Hand.position = $Hand.position.lerp(dest, delta / _move_hand_timer)
					_move_hand_timer -= delta
				else:
					$Hand.position = dest
					_current_cmd += 1
					_executing_cmd = false


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if event is InputEventScreenTouch:
			if event.pressed:
				if _current_cmd < _cmds.tutorial_script.size():
					var cmd := _cmds.tutorial_script[_current_cmd]
					match cmd.name:
						&"finger to":
							$Hand.position = Vector2(cmd.x, cmd.y)
							_move_hand_timer = 0.0
						&"wait":
							_current_cmd += 1
							_executing_cmd = false
		accept_event()
