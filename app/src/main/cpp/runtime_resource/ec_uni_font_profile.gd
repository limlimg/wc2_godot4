class_name ecUniFontProfile
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
