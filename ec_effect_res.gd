@tool
class_name ecEffectRes
extends Resource

@export
var asset: AssetRegistry:
	set(value):
		if value != asset:
			if asset != null:
				asset.changed.disconnect(_on_asset_changed)
			asset = value
			_on_asset_changed()
			if value != null:
				value.changed.connect(_on_asset_changed)


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


@export
var emitter: Array[ecEmitterAttr]:
	set(value):
		if value != emitter:
			emitter = value
			emit_changed()


func _on_asset_changed() -> void:
	if asset != null:
		var res: ecEffectRes
		if Engine.is_editor_hint():
			var path = EC2dAppDelegate.get_asset_path(asset.name, "")
			if path.is_empty():
				path = EC2dAppDelegate.get_asset_path(asset.name_hd, "")
			if not path.is_empty():
				res = load(path) as ecEffectRes
			else:
				res = null
		else:
			var name := asset.get_resolved_name()
			if not name.is_empty():
				var path = EC2dAppDelegate.get_asset_path(name, "")
				if not path.is_empty():
					res = load(path) as ecEffectRes
		if res != null:
			emitter = res.emitter
		else:
			emitter = []
	notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if asset != null and property.name == "emitter":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY
