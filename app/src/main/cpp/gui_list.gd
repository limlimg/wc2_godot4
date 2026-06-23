extends "res://app/src/main/cpp/gui_element.gd"

## Common component of GUIBattleList, GUICountryList and GUICardList.

@export
var vertical := true:
	get():
		return $CTouchInertia/ScrollContainer/BoxContainer.vertical
	set(value):
		$CTouchInertia/ScrollContainer/BoxContainer.vertical = value


var _selected_item := -1
var _scorll_value := 0.0

signal item_touched(item: int)

func _on_c_touch_inertia_touch_began(_position: Vector2) -> void:
	set_physics_process(false)


func _on_c_touch_inertia_touch_ended(pos: Vector2, moved: bool) -> void:
	if not moved:
		pos = get_global_transform() * pos
		var sel_item := _gel_sel_item(pos.x, pos.y)
		if sel_item >= 0 and sel_item != _selected_item:
			item_touched.emit(sel_item)


func _gel_sel_item(x: float, y: float) -> int:
	var a := $CTouchInertia/ScrollContainer/BoxContainer.get_children()
	for i in a.size():
		if a[i] is Control and (a[i].get_global_transform() * Rect2(Vector2.ZERO, a[i].size)).has_point(Vector2(x, y)):
			return i
	return -1


func _on_c_touch_inertia_inertia_ended() -> void:
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	var y: float = $CTouchInertia/ScrollContainer.position.y
	if y < 0.0:
		_add_scroll_vertial(min(y * delta * 5.0, -0.4))
	elif y > 0.0:
		_add_scroll_vertial(max(y * delta * 5.0, 0.4))
	else:
		set_physics_process(false)


func _on_c_touch_inertia_touch_moved(relative: Vector2) -> void:
	_add_scroll_vertial(-relative.y)


func _add_scroll_vertial(delta: float) -> void:
	if delta == 0.0:
		return
	if vertical:
		var overflow: float = $CTouchInertia/ScrollContainer.position.y
		var scroll: Range = $CTouchInertia/ScrollContainer.get_v_scroll_bar()
		var scroll_min := scroll.min_value
		var scroll_max: float = max(scroll.max_value - size.y, scroll_min)
		overflow = _calc_overflow(delta, overflow, scroll.value, scroll_min, scroll_max)
		$CTouchInertia/ScrollContainer.position.y = overflow
		scroll.value = _calc_scroll(overflow, scroll_min, scroll_max)
	else:
		var overflow: float = $CTouchInertia/ScrollContainer.position.x
		var scroll: Range = $CTouchInertia/ScrollContainer.get_h_scroll_bar()
		var scroll_min := scroll.min_value
		var scroll_max: float = max(scroll.max_value - size.x, scroll_min)
		overflow = _calc_overflow(delta, overflow, scroll.value, scroll_min, scroll_max)
		$CTouchInertia/ScrollContainer.position.x = overflow
		scroll.value = _calc_scroll(overflow, scroll_min, scroll_max)


func _calc_overflow(delta: float, cur_overflow: float, cur_scroll: float, scroll_min: float, scroll_max: float) -> float:
	if _scorll_value + cur_overflow != cur_scroll:
		_scorll_value = cur_scroll - cur_overflow
	_scorll_value += delta
	if _scorll_value < scroll_min:
		return scroll_min - _scorll_value
	else:
		if _scorll_value > scroll_max:
			return scroll_max - _scorll_value
		else:
			return 0.0


func _calc_scroll(overflow: float, scroll_min: float, scroll_max: float) -> float:
	if overflow > 0.0:
		return scroll_min
	elif overflow < 0.0:
		return scroll_max
	else:
		return _scorll_value


func clear_item() -> void:
	for c in $CTouchInertia/ScrollContainer/BoxContainer.get_children():
		$CTouchInertia/ScrollContainer/BoxContainer.remove_child(c)
		c.queue_free()
	_add_scroll_vertial(-_scorll_value)


func add_item(item: Node) -> void:
	$CTouchInertia/ScrollContainer/BoxContainer.add_child(item)


func get_items() -> Array[Node]:
	return $CTouchInertia/ScrollContainer/BoxContainer.get_children()


func set_select(index: int) -> void:
	_selected_item = index
