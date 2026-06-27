@tool
class_name ecEffectRes
extends Resource

const _AssetRegistry = preload("res://app/src/main/cpp/resources/assets/asset_registry.gd")
const _ecTextureRes = preload("res://app/src/main/cpp/ec_texture_res.gd")
const _ecEmitterAttr = preload("res://app/src/main/cpp/ec_emitter_attr.gd")
const _lib = preload("res://app/src/main/cpp/native-lib.gd")

@export
var asset: _AssetRegistry:
	set(value):
		if value != asset:
			if asset != null:
				asset.changed.disconnect(_on_asset_changed)
			asset = value
			_on_asset_changed()
			if value != null:
				value.changed.connect(_on_asset_changed)


@export
var texture_res: _ecTextureRes:
	set(value):
		if value != texture_res:
			if texture_res != null:
				texture_res.changed.disconnect(emit_changed)
			texture_res = value
			emit_changed()
			if value != null:
				value.changed.connect(emit_changed)


@export
var emitter: Array[_ecEmitterAttr]:
	set(value):
		if value != emitter:
			emitter = value
			emit_changed()


func _on_asset_changed() -> void:
	if asset != null:
		var res: ecEffectRes
		if Engine.is_editor_hint():
			print(asset.name)
			print(_lib.get_asset_path(asset.name, ""))
			res = load(_lib.get_asset_path(asset.name, "")) as ecEffectRes
			if res == null:
				res = load(_lib.get_asset_path(asset.name_hd, "")) as ecEffectRes
		else:
			var name := asset.get_resolved_name()
			if not name.is_empty():
				var path := _lib.get_asset_path(name, "")
				if not path.is_empty():
					res = load(path) as ecEffectRes
		if res != null:
			emitter = res.emitter
	notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if asset != null and property.name == "emitter":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY
