@tool
class_name GUIImage
extends GUIElement

@export
var texture_res: ecTextureRes:
	set(value):
		if value != texture_res:
			if texture_res != null:
				texture_res.changed.disconnect(init)
			elif not Engine.is_editor_hint():
				if s_texture_res.changed.is_connected(init):
					s_texture_res.changed.disconnect(init)
			texture_res = value
			init()
			if value != null:
				value.changed.connect(init)
			elif not Engine.is_editor_hint():
				s_texture_res.changed.connect(init)


@export
var asset: AssetRegistry:
	set(value):
		if value != asset:
			if asset != null:
				asset.changed.disconnect(init)
			asset = value
			init()
			if value != null:
				value.changed.connect(init)


@export
var texture: Texture2D:
	get():
		return $TextureRect.texture
	set(value):
		$TextureRect.texture = value


@export
var alpha := 1.0:
	get():
		return $TextureRect.self_modulate.a
	set(value):
		$TextureRect.self_modulate.a = value


@export_group("Texture Rect", "texture_")
@export
var texture_rect: ecTextureRect:
	set(value):
		if value != texture_rect:
			if texture_rect != null:
				texture_rect.changed.disconnect(init)
			texture_rect = value
			init()
			if value != null:
				value.changed.connect(init)


@export
var texture_rect_ipad: ecTextureRect:
	set(value):
		if value != texture_rect_ipad:
			if texture_rect_ipad != null:
				texture_rect_ipad.changed.disconnect(init)
			texture_rect_ipad = value
			init()
			if value != null:
				value.changed.connect(init)


@export
var texture_rect_640h: ecTextureRect:
	set(value):
		if value != texture_rect_640h:
			if texture_rect_640h != null:
				texture_rect_640h.changed.disconnect(init)
			texture_rect_640h = value
			init()
			if value != null:
				value.changed.connect(init)


@export
var texture_rect_568h: ecTextureRect:
	set(value):
		if value != texture_rect_568h:
			if texture_rect_568h != null:
				texture_rect_568h.changed.disconnect(init)
			texture_rect_568h = value
			init()
			if value != null:
				value.changed.connect(init)


func init() -> void:
	if not is_node_ready():
		return
	super()
	if asset != null:
		var selected_rect: ecTextureRect
		var graphics := ecGraphics.instance()
		if graphics.content_scale_size_mode == 3:
			selected_rect = texture_rect_ipad
		elif graphics.orientated_content_scale_width > 568.0:
			selected_rect = texture_rect_640h
		elif graphics.orientated_content_scale_width > 480.0:
			selected_rect = texture_rect_568h
		if selected_rect == null:
			selected_rect = texture_rect
		if selected_rect != null:
			var new_texture := ecImageAttr.new()
			if Engine.is_editor_hint():
				new_texture.texture = ecGraphics.instance().load_texture(asset.name)
				if new_texture.texture == null:
					new_texture.texture = ecGraphics.instance().load_texture(asset.name_hd)
			else:
				var texture_name := asset.get_resolved_name()
				if not texture_name.is_empty():
					new_texture.texture = ecGraphics.instance().load_texture(texture_name)
			new_texture.region = selected_rect.region
			new_texture.origin = selected_rect.origin
			texture = new_texture
		else:
			var res := texture_res
			if res == null:
				res = s_texture_res
			if res != null:
				if Engine.is_editor_hint():
					texture = texture_res.get_image(asset.name)
					if texture == null:
						texture = texture_res.get_image(asset.name_hd)
				else:
					var image_name := asset.get_resolved_name()
					if not image_name.is_empty():
						texture = res.get_image(image_name)
	notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if asset != null and property.name == "texture":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY


func _set_alpha(value: float) -> void:
	alpha = value


## The original method has more parameter for specifying texture format.
func set_image(texture_name: String, attr: ecTextureRect = null) -> bool:
	var new_texture := ecGraphics.instance().load_texture(texture_name)
	if new_texture == null:
		texture = null
		return false
	if attr != null:
		var new_image := ecImageAttr.new()
		new_image.texture = texture
		new_image.region = Rect2(attr.x, attr.y, attr.w, attr.h)
		new_image.ref = Vector2(attr.refx, attr.refy)
		texture = new_image
	else:
		texture = new_texture
	return true
