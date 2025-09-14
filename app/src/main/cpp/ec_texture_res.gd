extends "res://app/src/main/cpp/native-lib.gd"
## Like many other kinds of Resource, loading code is in the importer. However,
## the original game code often merges the entries from multiple files, so
## relavent methods are implemented here.

const _ecImageAttr = preload("res://app/src/main/cpp/ec_image_attr.gd")
const _ecTextureResFile = preload("res://app/src/main/cpp/ec_texture_res_file.gd")
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")

var _textures: Dictionary[StringName, Texture2D]
var _images: Dictionary[StringName, _ecImageAttr]


func release() -> void:
	var graphics := _ecGraphics.instance()
	for i in _textures.keys():
		graphics.free_texture(i)
	_textures.clear()
	_images.clear()


func load_res(file_name: String, hd: bool) -> void:
	var path := get_path(file_name, "")
	var res := load(path) as _ecTextureResFile
	if res == null:
		push_error("Failed to load {0}".format([file_name]))
		return
	var texture := create_texture(res.texture_name)
	if texture == null:
		push_error("Failed to load {0}".format([res.texture_name]))
		return
	if hd:
		var ec_texture := _ecTexture.new()
		ec_texture.texture = texture
		ec_texture.texture_scale = 2.0
		texture = ec_texture
	for k in res.images.keys():
		var rect := res.images[k]
		var x = rect.x
		var y = rect.y
		var w = rect.w
		var h = rect.h
		var refx = rect.refx
		var refy = rect.refy
		if hd:
			x /= 2.0
			y /= 2.0
			w /= 2.0
			h /= 2.0
			refx /= 2.0
			refy /= 2.0
		create_image_texture(k, texture, rect.x, rect.y, rect.w, rect.h, rect.refx, rect.refy)


func unload_res(file_name: String) -> void:
	var path := get_path(file_name, "")
	var res := load(path) as _ecTextureResFile
	if res == null:
		push_error("Failed to load {0}".format([file_name]))
		return
	for k in res.images.keys():
		_images.erase(k)


## In the original game code, this method has more parameters to specify the
## format of the texture.
func create_texture(texture_name: String) -> Texture2D:
	var texture: Texture2D = _textures.get(texture_name)
	if texture == null:
		texture = _ecGraphics.instance().load_texture(texture_name)
		_textures[texture_name] = texture
	return texture


func release_texture(texture_name: String) -> void:
	var texture: Texture2D = _textures.get(texture_name)
	if texture == null:
		return
	_ecGraphics.instance().free_texture(texture_name)


func get_texture(texture_name: String) -> Texture2D:
	return _textures.get(texture_name)


func create_image_texture_name(image_name: StringName, texture_name: String, x: float,
 		y: float, w: float, h: float, refx: float, refy: float) -> _ecImageAttr:
	var image: _ecImageAttr = _images.get(image_name)
	if image != null:
		return image
	var texture := get_texture(texture_name)
	if texture == null:
		texture = create_texture(texture_name)
	if texture == null:
		return null
	image = _ecImageAttr.new()
	image.texture = texture
	image.x = x
	image.y = y
	image.w = w
	image.h = h
	image.refx = refx
	image.refy = refy
	_images[image_name] = image
	return image


func create_image_texture(image_name: StringName, texture: Texture2D, x: float,
 		y: float, w: float, h: float, refx: float, refy: float) -> _ecImageAttr:
	var image: _ecImageAttr = _images.get(image_name)
	if image != null:
		return image
	image = _ecImageAttr.new()
	image.texture = texture
	image.x = x
	image.y = y
	image.w = w
	image.h = h
	image.refx = refx
	image.refy = refy
	_images[image_name] = image
	return image


func get_image(image_name: StringName) -> _ecImageAttr:
	return _images.get(image_name)
