extends "res://app/src/main/cpp/native-lib.gd"

## ecTextureRes stores collections of texture atlas. Image definitions from
## multiple .xml files can be merged by calling load_res multiple times.
## 
## Like with textures, an .xml file can define a standard or high-resolution
## atlas. In the original game code the second patameter of load_res decides
## whether a .xml file is regarded as standard or high-resolution. Generally,
## high-resolution atlas has "_hd" suffix in the file name. However, many files
## with the suffix are loaded as standard atlases when the content size is
## 1024 x 768 to make it twice the size as its counterpart in other content
## sizes.
## 
## To use images defined in ecTextureRes in the scene system, create ecImageAttr
## as texture and specify the source ecTextureRes, the second patameter of
## load_res and the name of the image.

const _ecImageAttr = preload("res://app/src/main/cpp/ec_image_attr.gd")
const _ecTextureRes = preload("res://app/src/main/cpp/imported_containers/ec_texture_res.gd")

var _textures: Dictionary[StringName, _ecTexture]
var _images: Dictionary[StringName, _ecImageAttr]

func release() -> void:
	var graphics := _ecGraphics.instance()
	for i in _textures.keys():
		graphics.free_texture(i)
	_textures.clear()
	_images.clear()


func load_res(file_name: String, hd: bool) -> bool:
	var path := get_path(file_name, "")
	var res := load(path) as _ecTextureRes
	if res == null:
		push_error("Failed to load {0}".format([file_name]))
		return false
	var texture := create_texture(res.texture_name)
	if texture == null:
		push_error("Failed to load {0}".format([res.texture_name]))
		return false
	if hd and texture.res_scale == 1.0:
		texture.size_override /= 2.0
		texture.res_scale = 2.0
	for k in res.images.keys():
		var image := res.images[k]
		var x: float
		var y: float
		var w: float
		var h: float
		var refx: float
		var refy: float
		if hd:
			x = image.x / 2.0
			y = image.y / 2.0
			w = image.w / 2.0
			h = image.h / 2.0
			refx = image.refx / 2.0
			refy = image.refy / 2.0
		else:
			x = image.x
			y = image.y
			w = image.w
			h = image.h
			refx = image.refx
			refy = image.refy
		create_image_texture(k, texture, x, y, w, h, refx, refy)
	return true


func unload_res(file_name: String) -> void:
	var path := get_path(file_name, "")
	var res := load(path) as _ecTextureRes
	if res == null:
		push_error("Failed to load {0}".format([file_name]))
		return
	for k in res.images.keys():
		_images.erase(k)


## In the original game code, this method has more parameters to specify the
## format of the texture.
func create_texture(texture_name: String) -> _ecTexture:
	var texture: _ecTexture = _textures.get(texture_name)
	if texture == null:
		if Engine.is_editor_hint():
			texture = ec_texture_load(texture_name)
		else:
			texture = _ecGraphics.instance().load_texture(texture_name)
		_textures[texture_name] = texture
	return texture


func release_texture(texture_name: String) -> void:
	var texture: Texture2D = _textures.get(texture_name)
	if texture == null:
		return
	_textures.erase(texture_name)
	if not Engine.is_editor_hint():
		_ecGraphics.instance().free_texture(texture_name)


func get_texture(texture_name: String) -> _ecTexture:
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
	image.region = Rect2(x, y, w, h)
	image.ref = Vector2(refx, refy)
	_images[image_name] = image
	return image


func create_image_texture(image_name: StringName, texture: _ecTexture, x: float,
 		y: float, w: float, h: float, refx: float, refy: float) -> _ecImageAttr:
	var image: _ecImageAttr = _images.get(image_name)
	if image != null:
		return image
	image = _ecImageAttr.new()
	image.texture = texture
	image.region = Rect2(x, y, w, h)
	image.ref = Vector2(refx, refy)
	_images[image_name] = image
	return image


func get_image(image_name: StringName) -> _ecImageAttr:
	return _images.get(image_name)
