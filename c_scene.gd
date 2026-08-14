class_name CScene
extends Control

var _area_enable: AreaEnable
var _area_list: Array[CArea]
var _render_area_list: Dictionary[int, Texture2D]
var _selected_area: CArea
var _flash_time: float
var flashing_red_area_id_1: int
var flashing_red_area_id_2: int
var _area_data: AreaDataList
var _area_mark := CAreaMark.new()
var _background: Control
var camera: Control
var _bomber: Node2D
var _medals: Array[Node2D]
var _v_arrow_y := 0.0
var _h_arrow_h := 0.2
var _adjoin: Adjoin
var _scene_rect: Rect2
var flashing_turn_begin: bool
var _canvas_item_disabled_areas: Dictionary[int, RID]
var _canvas_item_selected_area: RID
var _area_color: PackedColorArray
var _arrow_blue: ecImage
var _arrow_red: ecImage

# TODO: implement editor methods?

func init(areas_enable: String, map: int) -> void:
	_area_mark.init(map)
	_load_area_data(map)
	_load_adjoin(map)
	var real_scene := get_tree().get_first_node_in_group(&"g_Scene")
	visible = real_scene.is_visible_in_tree()
	_background = real_scene.get_node(^"CBackground").create_instance()
	_init_areas(map, areas_enable)
	_check_adjacent_area()
	_scene_rect = _cal_scene_rect()
	_background.init(map, Rect2(Vector2.ZERO, _area_mark.get_map_size()), _scene_rect)
	_create_render_area_list()
	_init_area_image(map)
	camera = real_scene.get_node(^"CCamera")
	camera.init(_scene_rect)
	_bomber = real_scene.get_node(^"CBomber").create_instance()
	_selected_area = null
	flashing_turn_begin = false
	flashing_red_area_id_1 = -1
	_flash_time = 0.0
	flashing_red_area_id_2 = -1
	real_scene.visibility_changed.connect(_render, CONNECT_ONE_SHOT)
	_canvas_item_selected_area = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(_canvas_item_selected_area, real_scene.get_node(^"SelectedOverlay").get_canvas_item())
	_arrow_blue = real_scene.get_node(^"SelectedOverlay/ArrowBlue")
	_arrow_blue.texture = g_GameRes.arrow_blue
	_arrow_red = real_scene.get_node(^"SelectedOverlay/ArrowRed")
	_arrow_red.texture = g_GameRes.arrow_red


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
	var cut_adjoin := Adjoin.new()
	cut_adjoin.index.append(0)
	for i in _adjoin.index.size() - 1:
		if _area_enable == null or _area_enable.enable[i]:
			var j = _adjoin.index[i]
			while j < _adjoin.index[i + 1]:
				var id := _adjoin.data[j]
				if _area_enable == null or _area_enable.enable[id]:
					cut_adjoin.data.append(_adjoin.data[j])
				j += 1
		cut_adjoin.index.append(cut_adjoin.data.size())
	_adjoin = cut_adjoin


func _load_area_tax(map: int) -> void:
	_clear_areas()
	var path = EC2dAppDelegate.get_asset_path("areatax{0}.xml".format([map]), "")
	if path.is_empty():
		return
	var area_tax: AreaTaxMap = load(path)
	var area_parent = get_tree().get_first_node_in_group(&"g_Scene").get_node(^"Areas").get_canvas_item()
	for k in area_tax.areas.keys():
		if _area_enable == null or _area_enable.enable[k]:
			var area := CArea.new()
			var info := AreaInfo.new()
			info.type = area_tax.areas[k].type
			info.tax = area_tax.areas[k].tax
			info.army_pos = _area_data.data[k].army_position
			info.construction_pos = _area_data.data[k].construction_position
			info.installation_pos = _area_data.data[k].installation_position
			info.sea = _area_data.data[k].sea
			area.init(k, info)
			RenderingServer.canvas_item_set_parent(area.canvas_item_root, area_parent)
			_area_list.append(area)
		else:
			_area_list.append(null)
	_area_color.resize(_area_list.size())


func _clear_areas() -> void:
	for i in _area_list:
		if i != null:
			i.free()
	_area_list.clear()
	_area_color.clear()
	for i in _canvas_item_disabled_areas.values():
		RenderingServer.free_rid(i)
	_canvas_item_disabled_areas.clear()
	_render_area_list.clear()


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
		if true or _is_rect_in_scene(_area_data.data[i].area_rect):
			_render_area_list[i] = null


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
	var disabled_area_parent_node := Node2D.new()
	_background.add_child(disabled_area_parent_node)
	var disabled_area_parent := disabled_area_parent_node.get_canvas_item()
	for k in _render_area_list.keys():
		_render_area_list[k] = zone_res.get_image("%04d.png"%k)
		if _area_enable != null and not _area_enable.enable[k]:
			var canvas_item := RenderingServer.canvas_item_create()
			RenderingServer.canvas_item_set_transform(canvas_item, Transform2D.IDENTITY.translated(-_background.position))
			RenderingServer.canvas_item_set_parent(canvas_item, disabled_area_parent)
			_canvas_item_disabled_areas[k] = canvas_item


func release() -> void:
	for i in _medals:
		i.queue_free()
	_medals.clear()
	_bomber.queue_free()
	_background.queue_free()
	_area_data = null
	_area_mark.release()
	_clear_areas()
	if _canvas_item_selected_area.is_valid():
		RenderingServer.free_rid(_canvas_item_selected_area)


func _render() -> void:
	visible = true
	for id in _render_area_list.keys():
		var canvas_item: RID
		if _area_list[id] != null:
			canvas_item = _area_list[id].canvas_item_root
			_area_list[id].render_building()
			_area_list[id].render()
		else:
			canvas_item = _canvas_item_disabled_areas[id]
		var texture := _render_area_list[id]
		var pos := _area_data.data[id].area_rect.position
		if texture != null:
			if EC2dAppDelegate.g_content_scale_factor != 1.0:
				texture.draw(canvas_item, pos)
			else:
				texture.draw_rect(canvas_item, Rect2(pos, texture.get_size() * 2), false)


func update(delta: float) -> void:
	camera.update(delta)
	if _bomber != null:
		_bomber.update(delta)
	var i := 0
	while i < _medals.size():
		var medal := _medals[i]
		if not medal.visible:
			medal.queue_free()
			_medals.remove_at(i)
		else:
			medal.update(delta)
			i += 1
	_flash_time += delta
	while _flash_time > 0.6:
		_flash_time -= 0.6
	_v_arrow_y -= 100.0 * delta
	while _v_arrow_y < -40.0:
		_v_arrow_y += 40.0
	_h_arrow_h += 0.9 * delta
	while _h_arrow_h > 2.25:
		_h_arrow_h -= 2.05
	var a := 0.5 + absf(_flash_time - 0.3)
	var y := -20.0 + absf(_v_arrow_y + 20.0)
	for id in _render_area_list.keys():
		var area := _area_list[id]
		if area != null:
			area.update(delta)
			var c: Color
			if area.country == null:
				c = Color(Color.BLUE, 0.0)
			elif id == flashing_red_area_id_1 or id == flashing_red_area_id_2:
				c = Color.from_rgba8(0xFF, 0x80, 0x80)
			else:
				c = area.country.color
				if area.sea != 0:
					c.a = 0.0
			if area == _selected_area\
				or id == flashing_red_area_id_1\
				or id == flashing_red_area_id_2\
				or flashing_turn_begin and area.country == g_GameManager.get_cur_country():
					c.a = a
			if c != _area_color[id]:
				RenderingServer.canvas_item_set_self_modulate(area.canvas_item_root, c)
				_area_color[id] = c
			var arrow: Texture2D
			if area.target == 1:
				arrow = g_GameRes.arrow_green
			elif area.target == 2:
				arrow = g_GameRes.arrow_yellow
			if arrow != null:
				RenderingServer.canvas_item_clear(area.canvas_item_arrow)
				var shadow = g_GameRes.arrow_shadow
				var shadow_pos := Vector2(-y, y) * 0.5
				var shadow_size = shadow.get_size() * EC2dAppDelegate.g_content_scale_factor
				shadow.draw_rect(area.canvas_item_arrow, Rect2(shadow_pos, shadow_size), false)
				arrow.draw(area.canvas_item_arrow, Vector2(0.0, y))
	var selected_area := get_selected_area()
	if selected_area != null:
		var graphics := ecGraphics.instance()
		graphics.render_begin(_canvas_item_selected_area)
		if selected_area.construction == 3:
			graphics.render_circle(selected_area.construction_pos.x, selected_area.construction_pos.y, selected_area.country.airstrike_radius(), Color.from_rgba8(0, 0, 0, 0x4F))
		elif selected_area.sea and selected_area.get_num_armies() > 0 and selected_area.get_army(0).def.id == 9:
			graphics.render_circle(selected_area.construction_pos.x, selected_area.construction_pos.y, selected_area.country.airstrike_radius(), Color.from_rgba8(0, 0, 0x80, 0x4F))
		var c := _h_arrow_h if _h_arrow_h <= 1.0 else 1.0 + (_h_arrow_h - 1.0) * 0.4
		for j in get_num_adjacent_areas(selected_area.id):
			var adj_area := get_adjacent_area(selected_area.id, j)
			if adj_area.target == 3 or adj_area.target == 4:
				var vy := adj_area.army_pos - selected_area.army_pos
				var vt := Transform2D(vy.rotated(PI / 2).normalized(), vy, adj_area.army_pos)
				var v0 := vt * Vector2(22.0, 0.0)
				var v1 := vt * Vector2(-22.0, 0.0)
				var v2 := vt * Vector2(-22.0, -1.0)
				var v3 := vt * Vector2(22.0, -1.0)
				var image: ecImage
				if adj_area.target == 3:
					image = _arrow_blue
				else:
					image = _arrow_red
				image.render_4vc(v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, v3.x, v3.y, 0, c)
		graphics.render_end()


func screen_area_id(x: float, y: float) -> int:
	var scene := screen_to_scene(x, y) as Vector2i
	return _area_mark.get_mark(scene.x, scene.y)


func screen_to_scene(x: float, y: float) -> Vector2:
	return camera.camera_position + (Vector2(x, y) - camera.size / 2) / camera.camera_zoom


func move(x: float, y: float) -> bool:
	return camera.move(x, y, false)


func move_to(x: float, y: float) -> void:
	camera.move_to(x, y, false)


func is_moving() -> bool:
	return camera.is_moving


func get_num_areas() -> int:
	return _area_data.data.size()


func screen_to_area(x: float, y: float) -> CArea:
	return get_area(screen_area_id(x, y))


func get_area(id: int) -> CArea:
	return _area_list.get(id)


func set_camera_to_area(id: int) -> void:
	var area := get_area(id)
	if area != null:
		camera.set_pos(area.army_pos.x, area.army_pos.y, true)


func move_camera_to_area(id: int) -> void:
	var area := get_area(id)
	if area != null:
		var area_rect := _area_data.data[area.id].area_rect
		if not camera.is_rect_in_visible_region(area_rect):
			camera.move_to(area.army_pos.x, area.army_pos.y, true)


func move_camera_center_to_area(id: int) -> void:
	var area := get_area(id)
	if area != null:
		camera.move_to(area.army_pos.x, area.army_pos.y, true)


func move_camera_between_area(id1: int, id2: int) -> void:
	var area1 := get_area(id1)
	if area1 == null:
		return
	var area2 := get_area(id2)
	if area2 == null:
		return
	if _is_rect_in_scene(_area_data.data[id1].area_rect) and _is_rect_in_scene(_area_data.data[id2].area_rect):
		return
	var target := (area1.army_pos + area2.army_pos) / 2
	camera.move_to(target.x, target.y)


func set_area_country(id: int, country: CCountry) -> void:
	var area = _area_list.get(id)
	if area != null:
		area.country = country


func get_selected_area() -> CArea:
	return _selected_area


func select_area(area) -> void:
	if typeof(area) == TYPE_INT:
		area = get_area(area)
	unselect_area()
	_selected_area = area
	_set_sel_area_target(area)


func unselect_area() -> void:
	if _selected_area != null:
		RenderingServer.canvas_item_clear(_canvas_item_selected_area)
	_selected_area = null
	clear_targets()


func reset_target() -> void:
	clear_targets()
	if _selected_area != null:
		_set_sel_area_target(_selected_area)


func clear_targets() -> void:
	for i in _area_list:
		if i != null and i.target != 0:
			RenderingServer.canvas_item_clear(i.canvas_item_arrow)
			i.target = 0


func _set_sel_area_target(sel_area: CArea) -> void:
	if sel_area.get_num_armies() <= 0:
		return
	if not sel_area.is_active():
		return
	var country := sel_area.country
	if country == null or country.ai:
		return
	var sel_area_id := sel_area.id
	var army_id := sel_area.get_army(0).def.id
	for i in get_num_adjacent_areas(sel_area_id):
		var adj_area_id := _get_adjacent_area_id(sel_area_id, i)
		if check_moveable(sel_area_id, adj_area_id, 0):
			get_area(adj_area_id).target = 3
			_create_arrow(sel_area_id, adj_area_id)
		elif army_id != 3 and army_id != 9 and check_attackable(sel_area_id, adj_area_id, 0):
			get_area(adj_area_id).target = 4
			_create_arrow(sel_area_id, adj_area_id)
		if army_id == 3:
			for j in get_num_adjacent_areas(adj_area_id):
				var area_2_id := _get_adjacent_area_id(adj_area_id, j)
				if check_attackable(sel_area_id, area_2_id, 0):
					g_Scene.get_area(area_2_id).target = 2
	if army_id == 9:
		for i in _area_list:
			if i != null and i.country != null and i.country.alliance != sel_area.country.alliance and i.get_num_armies() > 0:
				var d := _get_two_areas_distance(sel_area_id, i.id)
				if d <= 0.0:
					continue
				if d < sel_area.country.airstrike_radius():
					i.target = 2


func check_moveable(from: int, to: int, army_index: int) -> bool:
	if not check_adjacent(from, to):
		return false
	var from_area := get_area(from)
	var to_area := get_area(to)
	if from_area.country != to_area.country and to_area.get_num_armies() > 0:
		return false
	if army_index > from_area.get_num_armies():
		return false
	var army := from_area.get_army(army_index)
	if to_area.sea == 0:
		if to_area.get_num_armies() > 3:
			return false
		if army.is_navy():
			return false
	else:
		if not army.is_navy():
			if not from_area.has_army_card(army_index, 2):
				return false
			if to_area.get_num_armies() > 0 and to_area.get_army(0).is_navy():
				return false
			if to_area.get_num_armies() > 3:
				return false
		else:
			if to_area.get_num_armies() > 0:
				return false
	return army.movement > 0


func check_attackable(from: int, to: int, army_index: int) -> bool:
	var from_area := get_area(from)
	var to_area := get_area(to)
	if from_area.country == null:
		return false
	if to_area.country == null:
		return false
	if from_area.country.alliance == to_area.country.alliance:
		return false
	if from_area.get_num_armies() <= army_index:
		return false
	if to_area.get_num_armies() <= 0:
		return false
	var army := from_area.get_army(army_index)
	if army.movement <= 0:
		return false
	match army.def.id:
		3:
			if check_adjacent(from, to):
				return false
			for i in get_num_adjacent_areas(from):
				if check_adjacent(_get_adjacent_area_id(from, i), to):
					return true
			return false
		9:
			var d := _get_two_areas_distance(from, to)
			if d <= 0.0:
				return false
			return d < army.country.airstrike_radius()
		_:
			return check_adjacent(from, to)


func check_adjacent(from: int, to: int) -> bool:
	for i in get_num_adjacent_areas(from):
		if _get_adjacent_area_id(from, i) == to:
			return true
	return false


func get_num_adjacent_areas(id: int) -> int:
	return _adjoin.index[id + 1] - _adjoin.index[id]


func get_adjacent_area(id: int, index: int) -> CArea:
	return get_area(_get_adjacent_area_id(id, index))


func _get_adjacent_area_id(id: int, index: int) -> int:
	return _adjoin.data[_adjoin.index[id] + index]


func _get_two_areas_distance(id1: int, id2: int) -> float:
	return sqrt(_get_two_areas_distance_square(id1, id2))


func _get_two_areas_distance_square(id1: int, id2: int) -> float:
	var area1 := get_area(id1)
	if area1 == null:
		return 0.0
	var area2 := get_area(id2)
	if area2 == null:
		return 0.0
	return (area1.army_pos - area2.army_pos).length_squared()


func _create_arrow(_from: int, _to: int) -> void:
	_h_arrow_h = 0.2


func all_areas_encirclement() -> void:
	for i in _area_list:
		if i != null:
			i.encirclement()


func adjacent_areas_encirclement(id: int) -> void:
	var area := get_area(id)
	area.encirclement()
	for i in get_num_adjacent_areas(id):
		get_adjacent_area(id, i).encirclement()


func airborne(id: int) -> void:
	if _bomber == null:
		return
	_bomber.airborne(id)


func aircraft_carrier_bomb(attack_area: int, defend_area: int) -> void:
	if _bomber == null:
		return
	_bomber.aircraft_carrier_bomb(attack_area, defend_area)


func bomb_area(id: int, action_type: int) -> void:
	if _bomber == null:
		return
	_bomber.bomb_area(id, action_type)


func is_bombing() -> bool:
	if _bomber == null:
		return false
	return _bomber.is_bombing()


func gain_medal(x: float, y: float) -> void:
	var medal = get_tree().get_first_node_in_group(&"g_Scene").get_node(^"CMedal").create_instance()
	medal.position = Vector2(x, y)
	medal.hidden.connect(medal.queue_free)
