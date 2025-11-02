extends MeshTexture
 
const _ecImageTexture = preload("res://app/src/main/cpp/scene_system_resource/ec_image_texture.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")
const _ecImageAttr = preload("res://app/src/main/cpp/ec_image_attr.gd")

var texture_size_override: Vector2:
	set(value):
		if value != texture_size_override:
			texture_size_override = value
			_mesh_changed()


var region: Rect2:
	set(value):
		if value != region:
			region = value
			_mesh_changed()


var ref: Vector2:
	set(value):
		if value != ref:
			ref = value
			_mesh_changed()


func _mesh_changed() -> void:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	var v0 := -ref
	var v2 := -ref + region.size
	var v1 := Vector2(v2.x, v0.y)
	var v3 := Vector2(v0.x, v2.y)
	var uv0 := region.position / texture_size_override
	var uv2 := region.end / texture_size_override
	var uv1 := Vector2(uv2.x, uv0.y)
	var uv3 := Vector2(uv0.x, uv2.y)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector2Array([v0, v1, v2, v0, v2, v3])
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array([uv0, uv1, uv2, uv0, uv2, uv3])
	if mesh == null or mesh is not ArrayMesh:
		mesh = ArrayMesh.new()
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	image_size = region.size


static func from_ec_texture(ec_texture: _ecTexture) -> _ecImageTexture:
	var new_self := _ecImageTexture.new()
	new_self.set_ec_texture(ec_texture)
	return new_self


func set_ec_texture(ec_texture: _ecTexture) -> void:
	if ec_texture != null:
		base_texture = ec_texture.texture
		texture_size_override = ec_texture.size_override
		region = Rect2(Vector2.ZERO, ec_texture.size_override)
		ref = Vector2.ZERO
	else:
		base_texture = null


static func from_ec_image_attr(attr: _ecImageAttr) -> _ecImageTexture:
	var new_self := _ecImageTexture.new()
	new_self.set_ec_image_attr(attr)
	return new_self


func set_ec_image_attr(attr: _ecImageAttr) -> void:
	if attr != null:
		base_texture = attr.texture.texture
		texture_size_override = attr.texture.size_override
		region = attr.region
		ref = attr.ref
	else:
		base_texture = null
