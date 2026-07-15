extends Control

const _CCamera = preload("res://app/src/main/cpp/c_camera.gd")
const _CArea = preload("res://app/src/main/cpp/c_area.gd")
const _CCountry = preload("res://app/src/main/cpp/c_country.gd")
const _CAreaMark = preload("res://app/src/main/cpp/c_area_mark.gd")
const _AreaDataList = preload("res://app/src/main/cpp/resources/imported/area_data_list.gd")
const _lib = preload("res://app/src/main/cpp/native-lib.gd")
const _Adjoin = preload("res://app/src/main/cpp/resources/imported/adjoin.gd")
const _AreaEnable = preload("res://app/src/main/cpp/resources/imported/area_enable.gd")
const _AreaTaxMap = preload("res://app/src/main/cpp/resources/imported/area_tax_map.gd")

@export
var areas_enable: String:
	set(value):
		if value != areas_enable:
			areas_enable = value
			init()


@export
var map: int:
	set(value):
		if value != map:
			map = value
			init()


var camera: _CCamera
var _area_mark: _CAreaMark
var _area_data: _AreaDataList
var _adjoin: _Adjoin
var _area_enable: _AreaEnable
var _areas: Dictionary[int, _CArea]
var _disabled_areas: Dictionary[int, Sprite2D]
var _scene_rect: Rect2

signal move_camera_completed

func init() -> void:
	_area_mark.map = map
	_load_area_data()
	_load_adjoin()
	_init_areas()
	_check_adjacent_area()
	_scene_rect = _cal_scene_rect()
	_create_render_area_list()
	$CCamera/CBackground.map = map
	$CCamera/CBackground.scene_rect = _scene_rect
	$CCamera.scene_rect = _scene_rect


func _load_area_data() -> void:
	var path := _lib.get_asset_path("area{0}.bin".format([map]), "")
	if path.is_empty():
		return
	_area_data = load(path)


func _load_adjoin() -> void:
	var path := _lib.get_asset_path("adjion{0}.bin".format([map]), "")
	if path.is_empty():
		return
	_adjoin = load(path)


func _init_areas() -> void:
	_load_area_tax()
	var cut_adjoin := _Adjoin.new()
	cut_adjoin.index.append(0)
	for i in _adjoin.index.size() - 1:
		if _area_enable.enable[i]:
			var j = _adjoin.index[i]
			while j < _adjoin.index[i + 1]:
				cut_adjoin.data.append(_adjoin.data[j])
		cut_adjoin.index.append(cut_adjoin.data.size())
	_adjoin = cut_adjoin


func _load_area_tax() -> void:
	_clear_areas()
	_load_area_enable()
	var path := _lib.get_asset_path("areatax{0}.xml".format([map]), "")
	if path.is_empty():
		return
	var area_tax: _AreaTaxMap = load(path)
	for k in area_tax.areas.keys():
		if _area_enable == null or _area_enable.enable[k]:
			var area: _CArea = $CCamera/CArea.create_instance()
			area.area_tax = area_tax.areas[k]
			area.area_data = _area_data.data[k]
			$CCamera.add_child(area)
			_areas[k] = area


func _clear_areas() -> void:
	for i in _areas.values():
		i.queue_free()
	_areas.clear()
	for i in _disabled_areas.values():
		i.queue_free()
	_disabled_areas.clear()


func _load_area_enable() -> void:
	var path := _lib.get_asset_path(areas_enable, "")
	if path.is_empty():
		return
	_area_enable = load(path)


func _check_adjacent_area() -> void:
	# No idea what this method is supposed to do. Unlikely related to ios feature.
	pass


## In the original game code, half of screen size is subtracted from each side.
## In this port, to allow screen size to be dynamic, there is no such subtraction.
func _cal_scene_rect() -> Rect2:
	var i := 0
	while _area_enable != null and not _area_enable.enable[i]:
		i += 1
	if i == _area_enable.enable.size():
		return Rect2()
	var rect := _area_data.data[i].area_rect
	while i < _area_enable.enable.size():
		if _area_enable == null or _area_enable.enable[i]:
			rect = rect.merge(_area_data.data[i].area_rect)
	return rect


func _create_render_area_list() -> void:
	for i in _area_data.data.size():
		if _is_rect_in_scene(_area_data.data[i].area_rect) and not _area_enable.enable[i]:
			var area: Sprite2D = $CCamera/CBackground/DisabledArea.duplicate()
			area.position = _area_data.data[i].area_rect.position - $CCamera/CBackground.position
			$CCamera/CBackground.add_child(area)
			_disabled_areas[i] = area


func _is_rect_in_scene(rect: Rect2) -> bool:
	return _scene_rect.intersects(rect)


func all_areas_encirclement() -> void:
	pass


func get_num_areas() -> int:
	return 0


func get_area(id: int) -> _CArea:
	return null


func set_area_country(id: int, country: _CCountry) -> void:
	pass


func set_camera_to_area(id: int) -> void:
	pass


func clear_targets() -> void:
	pass


func reset_target() -> void:
	pass


func move_camera_to_area(id: int) -> void:
	pass


func move_camera_center_to_area(id: int) -> void:
	pass


func adjacent_areas_encirclement(id: int) -> void:
	pass


func get_num_adjacent_areas(id: int) -> int:
	return 0
