class_name ecElement
extends Node2D

@export
var lib: ecLibrary:
	set(value):
		if value != lib:
			lib = value
			if value != null and not motion_name.is_empty():
				_item_data = value.motion_items[motion_name]
			else:
				_item_data = null


@export
var motion_name: StringName:
	set(value):
		if value != motion_name:
			motion_name = value
			if lib != null and not value.is_empty():
				_item_data = lib.data.motion_items[motion_name]
			else:
				_item_data = null


@export
var loop: int:
	set = set_loop

@export
var cur_frame: int:
	set = set_cur_frame

@export
var shape_color := Color.WHITE:
	set(value):
		if value != shape_color:
			if element_data != null:
				value.a = element_data.alpha
			if _item_data is ecShapeData:
				for i in _nodes:
					i.self_modulate = shape_color


var element_data: ecElementData:
	set(value):
		if value != element_data:
			element_data = value
			_item_data = value.sub_item


var _item_data: ecItemData:
	set = _reset_item
	
var _nodes: Array[Node2D]
var _cur_frame_time: float
var _playing: bool

signal completed

func _reset_item(value: ecItemData) -> void:
	if value == _item_data:
		return
	for i in _nodes:
		i.queue_free()
	_nodes.clear()
	_item_data = value
	init()
	if element_data != null:
		set_loop(element_data.loop)
		set_cur_frame(element_data.initial_frame)
		shape_color = Color(Color.WHITE, element_data.alpha)
		for i in _nodes:
			i.transform = element_data.transform
			if _item_data is ecShapeData:
				i.self_modulate = shape_color


func init() -> void:
	if _item_data == null:
		return
	elif _item_data is ecShapeData:
		var shape := Sprite2D.new()
		if lib.texture_res != null:
			shape.texture = lib.texture_res.get_image(_item_data.item_name + ".png")
		shape.offset = _item_data.shape_position
		shape.centered = false
		add_child(shape)
		_nodes.append(shape)
	elif _item_data is ecMotionData:
		for i in _item_data.layers:
			var layer := ecLayer.new()
			layer.lib = lib
			layer.data = i
			layer.duration = _item_data.duration
			add_child(layer)
			move_child(layer, 0)
			_nodes.append(layer)
	loop = 0
	cur_frame = 0
	_playing = false
	_cur_frame_time = 0.0
	shape_color = Color.WHITE


func set_loop(value: int) -> void:
	loop = value
	if _item_data is ecMotionData:
		for i in _nodes:
			i.set_loop(value)


func set_cur_frame(value: int) -> void:
	if _item_data is ecMotionData:
		cur_frame = value
		for i in _nodes:
			i.set_cur_frame(value)


func reset() -> void:
	if element_data != null:
		set_cur_frame(element_data.initial_frame)


func play() -> void:
	_playing = true
	if _item_data is ecMotionData:
		for i in _nodes:
			i.play()


func next_frame() -> bool:
	if not _playing or _item_data == null\
		or _item_data is not ecMotionData or loop == 2:
			return false
	for i in _nodes:
		i.next_frame()
	cur_frame += 1
	if cur_frame < _item_data.duration:
		return false
	if loop == 1:
		_playing = false
	cur_frame = 0
	completed.emit()
	return true


func stop() -> void:
	_playing = false
	if _item_data is ecMotionData:
		for i in _nodes:
			i.stop()


func change_item(from: ecItemData, to: ecItemData) -> void:
	if _item_data == from:
		_reset_item(to)
	if _item_data is ecMotionData:
		for i in _nodes:
			i.change_item(from, to)


func get_play_time() -> float:
	if _item_data is ecMotionData:
		return _item_data.duration / lib.data.frame_rate
	return 0.0


func update(delta: float) -> bool:
	if not _playing or _item_data == null\
		or _item_data is not ecMotionData or loop == 2:
			return false
	_cur_frame_time += delta
	var end := false
	var d := 1.0 / lib.data.frame_rate
	while _cur_frame_time >= d:
		if next_frame():
			end = true
		_cur_frame_time -= d
	return end
