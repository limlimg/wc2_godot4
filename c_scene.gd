class_name CScene
extends Control

var camera: CCamera
var _area_mark := CAreaMark.new()
var _area_data: AreaDataList
var _adjoin: Adjoin
var _area_enable: AreaEnable
var _areas: Dictionary[int, CArea]
var _disabled_areas: Dictionary[int, Sprite2D]
var _scene_rect: Rect2

signal move_camera_completed

func init(areas_enable: String, map: int) -> void:
	_area_mark.init(map)
	_load_area_data(map)
	_loadAdjoin(map)
	_init_areas(map, areas_enable)
	_check_adjacent_area()
	_scene_rect = _cal_scene_rect()
	_create_render_area_list()
	$CCamera/CBackground.init(map, Rect2(Vector2.ZERO, _area_mark.get_map_size()), _scene_rect)
	$CCamera.init(_scene_rect)


func _load_area_data(map: int) -> void:
	var path = EC2dAppDelegate.get_asset_path("area{0}.bin".format([map]), "")
	if path.is_empty():
		return
	_area_data = load(path)


func _loadAdjoin(map: int) -> void:
	var path = EC2dAppDelegate.get_asset_path("adjion{0}.bin".format([map]), "")
	if path.is_empty():
		return
	_adjoin = load(path)


func _init_areas(map: int, areas_enable: String) -> void:
	if not areas_enable.is_empty():
		_load_area_enable(areas_enable)
	_load_area_tax(map)
	var cutAdjoin := Adjoin.new()
	cutAdjoin.index.append(0)
	for i in _adjoin.index.size() - 1:
		if _area_enable.enable[i]:
			var j = _adjoin.index[i]
			while j < _adjoin.index[i + 1]:
				cutAdjoin.data.append(_adjoin.data[j])
				j += 1
		cutAdjoin.index.append(cutAdjoin.data.size())
	_adjoin = cutAdjoin


func _load_area_tax(map: int) -> void:
	_clear_areas()
	var path = EC2dAppDelegate.get_asset_path("areatax{0}.xml".format([map]), "")
	if path.is_empty():
		return
	var area_tax: AreaTaxMap = load(path)
	for k in area_tax.areas.keys():
		if _area_enable == null or _area_enable.enable[k]:
			var area: CArea = $CCamera/CArea.create_instance()
			var info := AreaInfo.new()
			info.type = area_tax.areas[k].type
			info.tax = area_tax.areas[k].tax
			info.army_pos = _area_data.data[k].army_position
			info.construction_pos = _area_data.data[k].construction_position
			info.installation_pos = _area_data.data[k].installation_position
			info.sea = _area_data.data[k].sea
			area.init(k, info)
			_areas[k] = area


func _clear_areas() -> void:
	for i in _areas.values():
		i.queue_free()
	_areas.clear()
	for i in _disabled_areas.values():
		i.queue_free()
	_disabled_areas.clear()


func _load_area_enable(areas_enable: String) -> void:
	var path = EC2dAppDelegate.get_asset_path(areas_enable, "")
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
		i += 1
	return rect


func _create_render_area_list() -> void:
	for i in _area_data.data.size():
		if _is_rect_in_scene(_area_data.data[i].area_rect) and not _area_enable.enable[i]:
			var area: Sprite2D = $CCamera/CBackground/DisabledArea.duplicate()
			area.position = _area_data.data[i].area_rect.position as Vector2 - $CCamera/CBackground.position
			$CCamera/CBackground.add_child(area)
			_disabled_areas[i] = area


func _is_rect_in_scene(rect: Rect2) -> bool:
	return _scene_rect.intersects(rect)


func all_areas_encirclement() -> void:
	pass


func get_num_areas() -> int:
	return 0


func get_area(id: int) -> CArea:
	return _areas.get(id)


func set_area_country(id: int, country: CCountry) -> void:
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
