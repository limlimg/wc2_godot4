class_name CScene
extends Control

var camera: CCamera
var _area_mark := CAreaMark.new()
var _background: Control
var _camera: Control
var _bomber: Node2D
var _medals: Array[Node2D]
var _area_data: AreaDataList
var _adjoin: Adjoin
var _area_enable: AreaEnable
var _areas: Dictionary[int, CArea]
var _disabled_areas: Dictionary[int, Texture2D]
var _scene_rect: Rect2
var _canvas_item_disabled_areas: Dictionary[int, RID]

# TODO: implement editor methods?

func init(areas_enable: String, map: int) -> void:
	_area_mark.init(map)
	_load_area_data(map)
	_load_adjoin(map)
	var real_scene := get_tree().get_first_node_in_group(&"g_Scene")
	_background = real_scene.get_node(^"CCamera/CBackground").create_instance()
	_init_areas(map, areas_enable)
	_check_adjacent_area()
	_scene_rect = _cal_scene_rect()
	_background.init(map, Rect2(Vector2.ZERO, _area_mark.get_map_size()), _scene_rect)
	_create_render_area_list()
	_init_area_image(map)
	_camera = real_scene.get_node(^"CCamera")
	_camera.init(_scene_rect)
	_bomber = real_scene.get_node(^"CCamera/CBomber").create_instance()


func _load_area_data(map: int) -> void:
	var path = EC2dAppDelegate.get_asset_path("area{0}.bin".format([map]), "")
	if path.is_empty():
		return
	_area_data = load(path)


func _load_adjoin(map: int) -> void:
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
			var area = get_tree().get_first_node_in_group(&"g_Scene").get_node(^"CCamera/CArea").create_instance()
			area.offset = _area_data.data[k].area_rect.position
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
	for i in _canvas_item_disabled_areas.values():
		RenderingServer.free_rid(i)
	_canvas_item_disabled_areas.clear()
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
			_disabled_areas[i] = null


func _is_rect_in_scene(rect: Rect2) -> bool:
	return _scene_rect.intersects(rect)


func _init_area_image(map: int) -> void:
	var zone_res := ecTextureRes.new()
	var i := 1
	var j := 1
	var zone_name := "m{0}_zone{1}_{2}.xml".format([map, i, j])
	var zone_path := EC2dAppDelegate.get_asset_path(zone_name, "")
	while not zone_path.is_empty():
		while not zone_path.is_empty():
			zone_res.load_res(zone_name, false)
			j += 1
			zone_name = "m{0}_zone{1}_{2}.xml".format([map, i, j])
			zone_path = EC2dAppDelegate.get_asset_path(zone_name, "")
		i += 1
		j = 1
		zone_name = "m{0}_zone{1}_{2}.xml".format([map, i, j])
		zone_path = EC2dAppDelegate.get_asset_path(zone_name, "")
	i = 1
	zone_name = "m{0}_conquest_{1}.xml".format([map, i])
	zone_path = EC2dAppDelegate.get_asset_path(zone_name, "")
	while not zone_path.is_empty():
		zone_res.load_res(zone_name, false)
		i += 1
		zone_name = "m{0}_zone{1}_{2}.xml".format([map, i, j])
		zone_path = EC2dAppDelegate.get_asset_path(zone_name, "")
	for k in _areas.keys():
		_areas[k].texture = zone_res.get_image("%04d.png"%k)
	var parent_node := Node2D.new()
	_background.add_child(parent_node)
	var parent := parent_node.get_canvas_item()
	for k in _disabled_areas.keys():
		var texture := zone_res.get_image("%04d.png"%k)
		_disabled_areas[k] = texture
		if texture.texture is ecTexture and texture.texture.texture != null:
			while not texture.get_rid().is_valid():
				await texture.changed
			var canvas_item := RenderingServer.canvas_item_create()
			RenderingServer.canvas_item_set_parent(canvas_item, parent)
			_canvas_item_disabled_areas[k] = canvas_item
			texture.draw(canvas_item, _area_data.data[k].area_rect.position as Vector2 - _background.position)


func release() -> void:
	for i in _medals:
		i.queue_free()
	_medals.clear()
	_bomber.queue_free()
	_background.queue_free()
	_area_data = null
	_area_mark.release()
	_clear_areas()


func all_areas_encirclement() -> void:
	pass


func get_num_areas() -> int:
	return 0


func get_area(id: int) -> CArea:
	return _areas.get(id)


func set_area_country(id: int, country: CCountry) -> void:
	pass


func set_camera_to_area(id: int) -> void:
	var area := get_area(id)
	if area != null:
		_camera.set_pos(area.army_pos.x, area.army_pos.y, true)


func clear_targets() -> void:
	pass


func reset_target() -> void:
	pass


func move_camera_to_area(id: int) -> void:
	var area := get_area(id)
	if area != null:
		var area_rect := _area_data.data[area.id].area_rect
		if not _camera.is_rect_in_visible_region(area_rect):
			_camera.move_to(area.army_pos.x, area.army_pos.y, true)


func move_camera_center_to_area(id: int) -> void:
	var area := get_area(id)
	if area != null:
		_camera.move_to(area.army_pos.x, area.army_pos.y, true)


func adjacent_areas_encirclement(id: int) -> void:
	pass


func get_num_adjacent_areas(id: int) -> int:
	return 0


func is_moving() -> bool:
	return _camera.is_moving()


func select_area(area) -> void:
	if typeof(area) == TYPE_INT:
		area = get_area(area)


func unselect_area() -> void:
	pass
