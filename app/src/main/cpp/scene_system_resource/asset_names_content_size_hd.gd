@tool
class_name AssetNamesContentSizeHd
extends Resource

const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")

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
		if value != name_568hd:
			name_568hd = value
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
		if value != name_534hd:
			name_534hd = value
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
		if value != name_512hd:
			name_512hd = value
			emit_changed()


@export
var name_512hd: String:
	set(value):
		if value != name_512h:
			name_512h = value
			emit_changed()


func get_effective_name() -> String:
	var selected_name: String
	var language: String
	if not Engine.is_editor_hint():
		var graphics := _ecGraphics.instance()
		if graphics.content_scale_size_mode == 3:
			selected_name = name_ipad
		else:
			var w := graphics.orientated_content_scale_width
			if w > 568.0:
				selected_name = name_640h
			elif w > 534.0:
				selected_name = name_568h
			elif w == 534.0:
				selected_name = name_534h
			elif w == 512.0:
				selected_name = name_512h
		if selected_name.is_empty():
			selected_name = name
		language = _native.g_localizable_strings.get_string("language")
	else:
		selected_name = name
		language = "en"
	return selected_name.format([language])


func get_hd_name() -> String:
	var selected_name: String
	var language: String
	if not Engine.is_editor_hint():
		language = _native.g_localizable_strings.get_string("language")
		var graphics := _ecGraphics.instance()
		if graphics.content_scale_size_mode == 3:
			selected_name = name_ipad_hd
			if not name_ipad.is_empty():
				return selected_name.format([language])
		else:
			var w := graphics.orientated_content_scale_width
			if w > 568.0:
				selected_name = name_640hd
				if not name_640h.is_empty():
					return selected_name.format([language])
			elif w > 534.0:
				selected_name = name_568hd
				if not name_568h.is_empty():
					return selected_name.format([language])
			elif w == 534.0:
				selected_name = name_534hd
				if not name_534h.is_empty():
					return selected_name.format([language])
			elif w == 512.0:
				selected_name = name_512hd
				if not name_512h.is_empty():
					return selected_name.format([language])
		if selected_name.is_empty():
			selected_name = name_hd
	else:
		selected_name = name_hd
		language = "en"
	return selected_name.format([language])
