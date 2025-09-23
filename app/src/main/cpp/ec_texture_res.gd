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
	var res := load(path) as _ecTextureRes
	if res == null:
		push_error("Failed to load {0}".format([file_name]))
		return
	var texture := create_texture(res.texture_name)
	if texture == null:
		push_error("Failed to load {0}".format([res.texture_name]))
		return
	for k in res.images.keys():
		var attr := _ecImageAttr.new()
		if hd:
			attr.set_texture_res_name_hd(res.texture_name)
		else:
			attr.set_texture_res_name(res.texture_name)
		attr.set_image_name(k)
		_images[k] = attr


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
