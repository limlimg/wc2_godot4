extends "res://gui_element.gd"

## Common component of GUIBattleList, GUICountryList and GUICardList.

@export
var vertical := true:
	get():
		return $ScrollContainer/BoxContainer.vertical
	set(value):
		$ScrollContainer/BoxContainer.vertical = value


@export
var separation_ipad: int:
	set(value):
		if value != separation_ipad:
			separation_ipad = value
			if ecGraphics.instance().content_scale_size_mode == 3:
				$ScrollContainer/BoxContainer.remove_theme_constant_override(&"separation")
				$ScrollContainer/BoxContainer.add_theme_constant_override(&"separation", value)


@export
var separation: int:
	set(value):
		if value != separation:
			separation = value
			if ecGraphics.instance().content_scale_size_mode != 3:
				$ScrollContainer/BoxContainer.remove_theme_constant_override(&"separation")
				$ScrollContainer/BoxContainer.add_theme_constant_override(&"separation", value)


var _selected_item := -1
var _scorll_value := 0.0
var _items: Array[Node]

signal item_touched(item: int)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			$CTouchInertia.touch_begin(event.position.x, event.position.y, event.index)
			accept_event()
		else:
			if $CTouchInertia.touch_end(event.position.x, event.position.y, event.index):
				var pos = get_global_transform() * event.position
				var sel_item := _gel_sel_item(pos.x, pos.y)
				if sel_item >= 0 and sel_item != _selected_item:
					item_touched.emit(sel_item)
				accept_event()
	elif event is InputEventScreenDrag:
		if $CTouchInertia.touch_move(event.position.x, event.position.y, event.index):
			if vertical:
				_add_scroll(-event.relative.y)
			else:
				_add_scroll(-event.relative.x)


func _gel_sel_item(x: float, y: float) -> int:
	var a := $ScrollContainer/BoxContainer.get_children()
	for i in a.size():
		if a[i] is Control and (a[i].get_global_transform() * Rect2(Vector2.ZERO, a[i].size)).has_point(Vector2(x, y)):
			return i
	return -1


func _process(delta: float) -> void:
	$CTouchInertia.update(delta)
	if $CTouchInertia.touching:
		return
	var speed = $CTouchInertia.get_speed()
	if speed:
		if vertical:
			_add_scroll(-speed.y)
		else:
			_add_scroll(-speed.x)
	else:
		var d: float
		if vertical:
			d = $ScrollContainer.position.y
		else:
			d = $ScrollContainer.position.x
		if d < 0.0:
			_add_scroll(min(d * delta * 5.0, -0.4))
		elif d > 0.0:
			_add_scroll(max(d * delta * 5.0, 0.4))


func _add_scroll(delta: float) -> void:
	if delta == 0.0:
		return
	if vertical:
		var overflow: float = $ScrollContainer.position.y
		var scroll: Range = $ScrollContainer.get_v_scroll_bar()
		var scroll_min := scroll.min_value
		var scroll_max: float = max(scroll.max_value - size.y, scroll_min)
		overflow = _calc_overflow(delta, overflow, scroll.value, scroll_min, scroll_max)
		$ScrollContainer.position.y = overflow
		scroll.value = _calc_scroll(overflow, scroll_min, scroll_max)
	else:
		var overflow: float = $ScrollContainer.position.x
		var scroll: Range = $ScrollContainer.get_h_scroll_bar()
		var scroll_min := scroll.min_value
		var scroll_max: float = max(scroll.max_value - size.x, scroll_min)
		overflow = _calc_overflow(delta, overflow, scroll.value, scroll_min, scroll_max)
		$ScrollContainer.position.x = overflow
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
	for c in _items:
		c.queue_free()
	_items.clear()
	_add_scroll(-_scorll_value)


func add_item(item: Node) -> void:
	_items.append(item)
	$ScrollContainer/BoxContainer.add_child(item)


func get_items() -> Array[Node]:
	return $ScrollContainer/BoxContainer.get_children()


func set_select(index: int) -> void:
	_selected_item = index
