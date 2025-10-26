class_name ecTextureProfile
extends Resource

@export
var name: String:
	set(value):
		if value != name:
			name = value
			emit_changed()


@export_group("Content Size Variants")
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
