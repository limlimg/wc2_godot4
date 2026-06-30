extends Node2D

const _ecLibrary = preload("res://app/src/main/cpp/ec_library.gd")
const _ecTextureRes = preload("res://app/src/main/cpp/ec_texture_res.gd")
const _ecFrameData = preload("res://app/src/main/cpp/ec_frame_data.gd")
const _ecElement = preload("res://app/src/main/cpp/ec_element.gd")
const _ecItemData = preload("res://app/src/main/cpp/ec_item_data.gd")

var lib: _ecLibrary:
	set(value):
		if value != lib:
			lib = value
			for i in _elements:
				i.lib = value


var motion_name: StringName:
	set(value):
		if value != motion_name:
			motion_name = value
			for i in _elements:
				i.motion_name = value


var texture_res: _ecTextureRes:
	set(value):
		if value != texture_res:
			texture_res = value
			for i in _elements:
				i.texture_res = value


var data: _ecFrameData:
	set(value):
		if value != data:
			data = value
			init()


var _elements: Array[Node2D]

func init() -> void:
	var target_size := data.elements.size() if data != null else 0
	while _elements.size() > target_size:
		remove_child(_elements[-1])
		_elements.pop_back().queue_free()
	if target_size == 0:
		return
	while _elements.size() < target_size:
		var element = _ecElement.new()
		_elements.append(element)
	for i in target_size:
		_elements[i].data = data.elements[i]


func reset() -> void:
	for i in _elements:
		i.reset()


func change_item(from: _ecItemData, to: _ecItemData) -> void:
	for i in _elements:
		i.change_item(from, to)


func next_frame() -> void:
	for i in _elements:
		i.next_frame()


func play() -> void:
	for i in _elements:
		i.play()


func stop() -> void:
	for i in _elements:
		i.stop()
