@tool
class_name GUIButton
extends GUIElement

@export
var image_normal: AssetRegistry:
	set(value):
		if value != image_normal:
			if image_normal != null:
				image_normal.changed.disconnect(init)
			image_normal = value
			init()
			if value != null:
				value.changed.connect(init, CONNECT_REFERENCE_COUNTED)


@export
var image_pressed: AssetRegistry:
	set(value):
		if value != image_pressed:
			if image_pressed != null:
				image_pressed.changed.disconnect(init)
			image_pressed = value
			init()
			if value != null:
				value.changed.connect(init, CONNECT_REFERENCE_COUNTED)


@export
var image_glow: AssetRegistry:
	set(value):
		if value != image_glow:
			if image_glow != null:
				image_glow.changed.disconnect(init)
			image_glow = value
			init()
			if value != null:
				value.changed.connect(init, CONNECT_REFERENCE_COUNTED)


@export
var image_background: AssetRegistry:
	set(value):
		if value != image_background:
			if image_background != null:
				image_background.changed.disconnect(init)
			image_background = value
			init()
			if value != null:
				value.changed.connect(init, CONNECT_REFERENCE_COUNTED)


@export
var image_text_image: AssetRegistry:
	set(value):
		if value != image_text_image:
			if image_text_image != null:
				image_text_image.changed.disconnect(init)
			image_text_image = value
			init()
			if value != null:
				value.changed.connect(init, CONNECT_REFERENCE_COUNTED)


@export
var font: NodePath:
	set(value):
		if value != font:
			font = value
			$ecText.font = value


@export
var enable := true:
	set(value):
		if value != enable:
			enable = value
			$TextureButton.disabled = not value
			_on_render()


@export
var play_sound_when_pressed := true

@export
var grey_when_pressed := false:
	set(value):
		if value != grey_when_pressed:
			grey_when_pressed = value
			_on_render()


@export_range(0.0, 1.0, 1.0/255.0)
var grey_scale := 1.0:
	set(value):
		if value != grey_scale:
			grey_scale = value
			_on_render()


@export_range(0.0, 1.0, 1.0/255.0)
var alpha := 1.0:
	set = set_alpha

@export_group("Textures", "texture_")
@export
var texture_normal: Texture2D:
	set(value):
		if value != texture_normal:
			texture_normal = value
			$TextureButton.texture_normal = value


@export
var texture_pressed: Texture2D:
	set(value):
		if value != texture_pressed:
			texture_pressed = value
			$TextureButton.texture_pressed = value


@export
var texture_background: Texture2D:
	set(value):
		if value != texture_background:
			texture_background = value
			$Background.texture = value


@export
var texture_glow: Texture2D:
	set(value):
		if value != texture_glow:
			texture_glow = value
			$Glow.texture = value


@export
var texture_text_image: Texture2D:
	set(value):
		if value != texture_text_image:
			texture_text_image = value
			$TextImage.texture = value


@export_group("Text", "text_")
@export
var text: String:
	set = set_text

@export
var text_font: NodePath:
	set(value):
		if value != text_font:
			text_font = value
			$ecText.font = value


@export
var text_color := Color.WHITE:
	set = set_text_color

@export
var text_offset: Vector2:
	set = set_text_offset

@export
var text_align: HorizontalAlignment:
	set = set_text_align

signal pressed

func _ready():
	super()
	_on_render()


func init() -> void:
	if not is_node_ready():
		return
	super()
	var res := texture_res
	if res == null:
		res = s_texture_res
	if res != null:
		if image_normal != null:
			if Engine.is_editor_hint():
				texture_normal = texture_res.get_image(image_normal.name)
				if texture_normal == null:
					texture_normal = texture_res.get_image(image_normal.name_hd)
			else:
				var image_name := image_normal.get_resolved_name()
				if not image_name.is_empty():
					texture_normal = res.get_image(image_name)
		if image_pressed != null:
			if Engine.is_editor_hint():
				texture_pressed = texture_res.get_image(image_pressed.name)
				if texture_pressed == null:
					texture_pressed = texture_res.get_image(image_pressed.name_hd)
			else:
				var image_name := image_pressed.get_resolved_name()
				if not image_name.is_empty():
					texture_pressed = res.get_image(image_name)
		if image_glow != null:
			if Engine.is_editor_hint():
				texture_glow = texture_res.get_image(image_glow.name)
				if texture_glow == null:
					texture_glow = texture_res.get_image(image_glow.name_hd)
			else:
				var image_name := image_glow.get_resolved_name()
				if not image_name.is_empty():
					texture_glow = res.get_image(image_name)
		if image_background != null:
			if Engine.is_editor_hint():
				texture_background = texture_res.get_image(image_background.name)
				if texture_background == null:
					texture_background = texture_res.get_image(image_background.name_hd)
			else:
				var image_name := image_background.get_resolved_name()
				if not image_name.is_empty():
					texture_background = res.get_image(image_name)
		if image_text_image != null:
			if Engine.is_editor_hint():
				texture_text_image = texture_res.get_image(image_text_image.name)
				if texture_text_image == null:
					texture_text_image = texture_res.get_image(image_text_image.name_hd)
			else:
				var image_name := image_text_image.get_resolved_name()
				if not image_name.is_empty():
					texture_text_image = res.get_image(image_name)
	notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if image_normal != null and property.name == "texture_normal":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if image_pressed != null and property.name == "texture_pressed":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if image_glow != null and property.name == "texture_glow":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if image_background != null and property.name == "texture_background":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if image_text_image != null and property.name == "texture_text_image":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY


func _on_render():
	if $TextureButton.button_pressed:
		$Glow.show()
		$Glow.self_modulate = Color(Color.WHITE * grey_scale, alpha)
	else:
		$Glow.hide()
	if not enable:
		var color := Color8(110, 110, 110) * grey_scale
		$TextureButton.self_modulate = Color(color, alpha)
	else:
		if grey_when_pressed and $TextureButton.button_pressed:
			var color := Color8(210, 210, 210) * grey_scale
			$TextureButton.self_modulate = Color(color, alpha)
		else:
			$TextureButton.self_modulate = Color(Color.WHITE * grey_scale, alpha)
	if grey_when_pressed and $TextureButton.button_pressed:
		var color := Color8(210, 210, 210) * grey_scale
		$TextImage.self_modulate = Color(color, alpha)
	else:
		$TextImage.self_modulate = Color(grey_scale, grey_scale, grey_scale, alpha)


func _set_glow(image_name: StringName) -> void:
	var res := texture_res
	if res == null:
		res = s_texture_res
	if res != null:
		texture_glow = res.get_image(image_name)


func _set_background(image_name: StringName) -> void:
	var res := texture_res
	if res == null:
		res = s_texture_res
	if res != null:
		texture_background = res.get_image(image_name)


func set_text(value: String) -> void:
	if value != text:
		text = value
		$ecText.text = value


func set_text_color(value: Color) -> void:
	if value != text_color:
		text_color = value
		$ecText.remove_theme_color_override(&"font_color")
		$ecText.add_theme_color_override(&"font_color", value)


func set_text_offset(value: Vector2) -> void:
	if value != text_offset:
		text_offset = value
		$ecText.offset_left = value.x
		$ecText.offset_right = value.x
		$ecText.offset_top = value.y
		$ecText.offset_bottom = value.y


func set_text_align(value: HorizontalAlignment) -> void:
	if value != text_align:
		text_align = value
		$ecText.horizontal_alignment = value
		match value:
			HORIZONTAL_ALIGNMENT_RIGHT:
				$ecText.grow_horizontal = GROW_DIRECTION_END
			HORIZONTAL_ALIGNMENT_CENTER:
				$ecText.grow_horizontal = GROW_DIRECTION_BOTH
			_:
				$ecText.grow_horizontal = GROW_DIRECTION_BEGIN


func set_text_image(image_name: StringName) -> void:
	var res := texture_res
	if res == null:
		res = s_texture_res
	texture_text_image = res.get_image(image_name)


func set_alpha(value: float) -> void:
	if value != alpha:
		alpha = value
		_on_render()


func _on_texture_button_button_down() -> void:
	_on_render()


func _on_texture_button_button_up() -> void:
	_on_render()


func _on_texture_button_pressed() -> void:
	if play_sound_when_pressed:
		CSoundBox.get_instance().play_se("btn.wav")
	pressed.emit()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
