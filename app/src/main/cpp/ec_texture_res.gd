class_name ecTextureRes
extends Resource

## Like many other kinds of Resource, loading code is in the importer. However,
## the original game code often merges the entries from multiple files, so
## relavent methods are implemented here.

const _ecImageAttr = preload("res://app/src/main/cpp/ec_image_attr.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _ecTextureRes = preload("res://app/src/main/cpp/ec_texture_res.gd")

@export
var images: Dictionary[StringName, _ecImageAttr]

func release() -> void:
	images.clear()


func load_res(file_name: String, hd: bool) -> void:
	var path := _native.get_path(file_name, "")
	var res := load(path) as _ecTextureRes
	if res == null:
		push_error("Failed to load {0}".format([file_name]))
		return
	if hd:
		for i in res.images.values():
			i.texture_scale = 2.0
	images.merge(res.images, true)


func unload_res(file_name: String) -> void:
	var path := _native.get_path(file_name, "")
	var res := load(path) as _ecTextureRes
	if res == null:
		push_error("Failed to load {0}".format([file_name]))
		return
	for k in res.images.keys():
		images.erase(k)


func get_image(name: StringName) -> _ecImageAttr:
	return images.get(name)
