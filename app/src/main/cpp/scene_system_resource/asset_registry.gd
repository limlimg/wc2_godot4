@tool
class_name AssetRegistry
extends Resource

const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")
const _lib = preload("res://app/src/main/cpp/native-lib.gd")

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
	var graphics := _ecGraphics.instance()
	if graphics.content_scale_size_mode == 3:
		return _select(name_ipad_hd, name_ipad, name_hd, name)
	elif graphics.orientated_content_scale_width > 568.0:
		return _select(name_640hd, name_640h, name_hd, name)
	elif graphics.orientated_content_scale_width > 534.0:
		return _select(name_568hd, name_568h, name_hd, name)
	elif graphics.orientated_content_scale_width == 534.0:
		return _select(name_534hd, name_534h, name_hd, name)
	elif graphics.orientated_content_scale_width == 512.0:
		return _select(name_512hd, name_512h, name_hd, name)
	else:
		return name_hd if _lib.g_content_scale_factor == 2.0 and not name_hd.is_empty() else name


func _select(s1: String, s2: String, s3: String, s4: String) -> String:
	if _lib.g_content_scale_factor == 2.0 and not s1.is_empty():
		return s1
	if not s2.is_empty():
		return s2
	if _lib.g_content_scale_factor == 2.0 and not s3.is_empty():
		return s3
	return s4


func is_hd() -> bool:
	if _lib.g_content_scale_factor != 2.0:
		return false
	var graphics := _ecGraphics.instance()
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
