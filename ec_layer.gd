class_name ecLayer
extends Node2D

var lib: ecLibrary:
	set(value):
		if value != lib:
			lib = value
			for i in _frames:
				i.lib = value


var motion_name: StringName:
	set(value):
		if value != motion_name:
			motion_name = value
			for i in _frames:
				i.motion_name = value


var texture_res: ecTextureRes:
	set(value):
		if value != texture_res:
			texture_res = value
			for i in _frames:
				i.texture_res = value


var data: ecLayerData:
	set(value):
		if value != data:
			data = value
			init()


var loop: int

var cur_frame: int:
	set = set_cur_frame

var duration: int

var _frames: Array[Node2D]

func init() -> void:
	var target_size := data.frames.size() if data != null else 0
	while _frames.size() > target_size:
		remove_child(_frames[-1])
		_frames.pop_back().queue_free()
	if target_size == 0:
		return
	while _frames.size() < target_size:
		var frame = ecFrame.new()
		frame.visible = false
		add_child(frame)
		_frames.append(frame)
	for i in target_size:
		_frames[i].lib = lib
		_frames[i].data = data.frames[i]
	set_loop(0)
	cur_frame = 0
	_frames[0].visible = true


func set_loop(value: int) -> void:
	loop = value


func set_cur_frame(tick: int) -> void:
	if tick != cur_frame:
		cur_frame = tick
		for i in data.frames.size():
			if tick >= data.frames[i].start_tick:
				_frames[i - 1].visible = false
				_frames[i].visible = true
			else:
				_frames[i].visible = false
				return
		if loop == 0:
			_frames[-1].visible = false
			_frames[0].visible = true


func next_frame() -> void:
	if loop == 2:
		return
	var frames := data.frames
	var i := _frames.find_custom(func (x): return x.visible)
	if loop == 1 and i == _frames.size() - 1:
		return
	cur_frame += 1
	if i != _frames.size() - 1:
		if cur_frame >= frames[i + 1].start_tick:
			_frames[i].visible = false
			_frames[i + 1].visible = true
			_frames[i + 1].reset()
		else:
			_frames[i].next_frame()
	elif cur_frame < duration:
		_frames[i].next_frame()
	else:
		if loop == 0:
			_frames[-1].visible = false
			_frames[0].visible = true
			cur_frame = 0
			_frames[0].reset()
		else:
			_frames[-1].reset()


func change_item(from: ecItemData, to: ecItemData) -> void:
	for i in _frames:
		i.change_item(from, to)


func play() -> void:
	for i in _frames:
		i.play()


func stop() -> void:
	for i in _frames:
		i.stop()
