@tool
class_name GUIImage
extends GUIElement

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
var alpha := 1.0:
	get():
		return $TextureRect.self_modulate.a
	set(value):
		$TextureRect.self_modulate.a = value


@export
var texture: Texture2D:
	get():
		return $TextureRect.texture
	set(value):
		$TextureRect.texture = value


func _on_asset_changed() -> void:
	if asset != null:
		if Engine.is_editor_hint():
			texture = ecGraphics.instance().load_texture(asset.name)
			if texture == null:
				texture = ecGraphics.instance().load_texture(asset.name_hd)
		else:
			var texture_name := await asset.get_resolved_name()
			if not texture_name.is_empty():
				texture = ecGraphics.instance().load_texture(texture_name)
	notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if asset != null and property.name == "texture":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY


## The original method has more parameters for specifying texture format.
func init_texture(texture_name: String, attr: ecTextureRect, rect: Rect2) -> bool:
	position = rect.position
	size = rect.size
	return set_image(texture_name, attr)


#func init_image_attr(image_name: StringName, rect: Rect2) -> bool:
	#position = rect.position
	#size = rect.size
	#texture = _ecImageTexture.from_ec_image_attr(s_texture_res.get_image(image_name))
	#return texture != null


func _set_alpha(value: float) -> void:
	alpha = value


## The original method has more parameter for specifying texture format.
func set_image(texture_name: String, attr: ecTextureRect) -> bool:
	var new_image := ecImageAttr.new()
	new_image.texture = ecGraphics.instance().load_texture(texture_name)
	new_image.region = Rect2(attr.x, attr.y, attr.w, attr.h)
	new_image.ref = Vector2(attr.refx, attr.refy)
	texture = new_image
	return texture != null
