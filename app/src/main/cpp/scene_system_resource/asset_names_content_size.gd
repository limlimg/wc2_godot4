@tool
class_name AssetNamesContentSize
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
var name_ipad: String:
	set(value):
		if value != name_ipad:
			name_ipad = value
			emit_changed()


@export
var name_640h: String:
	set(value):
		if value != name_640h:
			name_640h = value
			emit_changed()


@export
var name_568h: String:
	set(value):
		if value != name_568h:
			name_568h = value
			emit_changed()


@export
var name_534h: String:
	set(value):
		if value != name_534h:
			name_534h = value
			emit_changed()


@export
var name_512h: String:
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
