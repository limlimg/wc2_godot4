extends Node2D

const _ecLibrary = preload("res://app/src/main/cpp/ec_library.gd")
const _ecItemData = preload("res://app/src/main/cpp/ec_item_data.gd")
const _ecElementData = preload("res://app/src/main/cpp/ec_element_data.gd")
const _ecShapeData = preload("res://app/src/main/cpp/resources/imported/ec_shape_data.gd")
const _ecMotionData = preload("res://app/src/main/cpp/resources/imported/ec_motion_data.gd")
const _ecLayer = preload("res://app/src/main/cpp/ec_layer.gd")

@export
var lib: _ecLibrary:
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
			if _item_data is _ecShapeData:
				for i in _nodes:
					i.self_modulate = shape_color


var element_data: _ecElementData:
	set(value):
		if value != element_data:
			element_data = value
			_item_data = value.sub_item


var _item_data: _ecItemData:
	set = _reset_item
	
var _nodes: Array[Node2D]
var _tween_play: Tween

signal completed

func _reset_item(value: _ecItemData) -> void:
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
			if _item_data is _ecShapeData:
				i.self_modulate = shape_color


func init() -> void:
	if _item_data == null:
		return
	elif _item_data is _ecShapeData:
		var shape := Sprite2D.new()
		if lib.texture_res != null:
			shape.texture = lib.texture_res.get_image(_item_data.item_name)
		shape.position = _item_data.shape_position
		add_child(shape)
		_nodes.append(shape)
	elif _item_data is _ecMotionData:
		for i in _item_data.layers:
			var layer := _ecLayer.new()
			layer.lib = lib
			layer.data = i
			layer.duration = _item_data.duration
			add_child(layer)
			_nodes.append(layer)
	loop = 0
	cur_frame = 0
	shape_color = Color.WHITE


func set_loop(value: int) -> void:
	loop = value
	if _item_data is _ecMotionData:
		for i in _nodes:
			i.set_loop(value)


func set_cur_frame(value: int) -> void:
	if _item_data is _ecMotionData:
		cur_frame = value
		for i in _nodes:
			i.set_cur_frame(value)


func reset() -> void:
	if element_data != null:
		set_cur_frame(element_data.initial_frame)


func play() -> void:
	if _tween_play != null:
		_tween_play.kill()
	_tween_play = create_tween()
	_tween_play.tween_interval(1.0 / lib.data.frame_rate)
	_tween_play.tween_callback(next_frame)
	_tween_play.set_loops()
	if _item_data is _ecMotionData:
		for i in _nodes:
			i.play()


func next_frame() -> bool:
	if _tween_play == null or _item_data == null\
		or _item_data is not _ecMotionData or loop == 2:
			return false
	for i in _nodes:
		i.next_frame()
	cur_frame += 1
	if cur_frame < _item_data.duration:
		return false
	if loop == 1:
		_tween_play.kill()
		_tween_play = null
	cur_frame = 0
	completed.emit()
	return true


func stop() -> void:
	if _tween_play != null:
		_tween_play.kill()
		_tween_play = null
	if _item_data is _ecMotionData:
		for i in _nodes:
			i.stop()


func change_item(from: _ecItemData, to: _ecItemData) -> void:
	if _item_data == from:
		_reset_item(to)
	if _item_data is _ecMotionData:
		for i in _nodes:
			i.change_item(from, to)


func get_play_time() -> float:
	if _item_data is _ecMotionData:
		return _item_data.duration / lib.data.frame_rate
	return 0.0
