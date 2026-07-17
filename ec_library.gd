class_name ecLibrary
extends Resource

@export
var data: ecLibraryData:
	set(value):
		if value != data:
			if data != null:
				data.changed.disconnect(emit_changed)
			data = value
			emit_changed()
			if value != null:
				value.changed.connect(emit_changed)


@export
var texture_res: ecTextureRes:
	set(value):
		if value != texture_res:
			if texture_res != null:
				texture_res.changed.disconnect(emit_changed)
			texture_res = value
			emit_changed()
			if value != null:
				value.changed.connect(emit_changed)


func load_data(name: String) -> void:
	var path := AppDelegate.get_asset_path(name, "")
	if path.is_empty():
		return
	data = load(path)
