@tool
class_name AssetRegistry
extends Resource

@export
var name: String:
	set(value):
		if value != name:
			name = value
			emit_changed()


@export
var name_hd: String:
	set(value):
		if value != name_hd:
			name_hd = value
			emit_changed()


@export
var name_ipad: String:
	set(value):
		if value != name_ipad:
			name_ipad = value
			emit_changed()


@export
var name_ipad_hd: String:
	set(value):
		if value != name_ipad_hd:
			name_ipad_hd = value
			emit_changed()


@export
var name_640h: String:
	set(value):
		if value != name_640h:
			name_640h = value
			emit_changed()


@export
var name_640hd: String:
	set(value):
		if value != name_640hd:
			name_640hd = value
			emit_changed()


@export
var name_568h: String:
	set(value):
		if value != name_568h:
			name_568h = value
			emit_changed()


@export
var name_568hd: String:
	set(value):
		if value != name_568hd:
			name_568hd = value
			emit_changed()


@export
var name_534h: String:
	set(value):
		if value != name_534h:
			name_534h = value
			emit_changed()


@export
var name_534hd: String:
	set(value):
		if value != name_534hd:
			name_534hd = value
			emit_changed()


@export
var name_512h: String:
	set(value):
		if value != name_512h:
			name_512h = value
			emit_changed()


@export
var name_512hd: String:
	set(value):
		if value != name_512hd:
			name_512hd = value
			emit_changed()


func get_resolved_name() -> String:
	var graphics := ecGraphics.instance()
	if not graphics.is_node_ready():
		await graphics.ready
	if graphics.content_scale_size_mode == 3:
		return _select([name_ipad_hd, name_ipad, name_hd, name])
	else:
		var queue: Array[String]
		if graphics.orientated_content_scale_width > 568.0:
			queue.append_array([name_640hd, name_640h])
		if graphics.orientated_content_scale_width > 534.0:
			queue.append_array([name_568hd, name_568h])
		if graphics.orientated_content_scale_width == 534.0:
			queue.append_array([name_534hd, name_534h])
		if graphics.orientated_content_scale_width == 512.0:
			queue.append_array([name_512hd, name_512h])
		queue.append_array([name_hd, name])
		return _select(queue)


func _select(queue: Array[String]) -> String:
	var s2: String
	while not queue.is_empty():
		var s1 = queue.pop_front()
		if EC2dAppDelegate.g_content_scale_factor == 2.0 and not s1.is_empty():
			return s1
		s2 = queue.pop_front()
		if not s2.is_empty():
			return s2
	return s2


func is_hd() -> bool:
	if EC2dAppDelegate.g_content_scale_factor != 2.0:
		return false
	var graphics := ecGraphics.instance()
	if not graphics.is_node_ready():
		await graphics.ready
	if graphics.content_scale_size_mode == 3:
		return not name_ipad_hd.is_empty() or name_ipad.is_empty() and not name_hd.is_empty()
	elif graphics.orientated_content_scale_width > 568.0:
		return not name_640hd.is_empty() or name_640h.is_empty() and not name_hd.is_empty()
	elif graphics.orientated_content_scale_width > 534.0:
		return not name_568hd.is_empty() or name_568h.is_empty() and not name_hd.is_empty()
	elif graphics.orientated_content_scale_width == 534.0:
		return not name_534hd.is_empty() or name_534h.is_empty() and not name_hd.is_empty()
	elif graphics.orientated_content_scale_width == 512.0:
		return not name_512hd.is_empty() or name_512h.is_empty() and not name_hd.is_empty()
	else:
		return not name_hd.is_empty()
