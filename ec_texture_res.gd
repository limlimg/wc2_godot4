@tool
class_name ecTextureRes
extends Resource

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

@export
var assets: Array[AssetRegistry]:
	set(value):
		if value != assets:
			var _cache_images = images
			images = {}
			assets = value
			for i in value:
				if i == null:
					continue
				if Engine.is_editor_hint():
					if not load_res(i.name, false):
						load_res(i.name_hd, true)
				else:
					var name := i.get_resolved_name()
					if not name.is_empty():
						load_res(name, i.is_hd())
			notify_property_list_changed()


@export
var images: Dictionary[StringName, ecImageAttr]:
	set(value):
		if value != images:
			images = value
			emit_changed()


func _validate_property(property: Dictionary) -> void:
	if not assets.is_empty() and property.name == "images":
		property.usage &= ~PROPERTY_USAGE_STORAGE
		property.usage |= PROPERTY_USAGE_READ_ONLY


func release() -> void:
	images.clear()


func load_res(file_name: String, hd: bool) -> bool:
	var path = EC2dAppDelegate.get_asset_path(file_name, "")
	if path.is_empty():
		return false
	var res := load(path) as ecTextureRes
	if res == null:
		push_error("Failed to load {0}".format([file_name]))
		return false
	var add_images := res.images
	if hd:
		for k in res.images.keys():
			if k in images:
				continue
			var hd_attr := res.images[k].duplicate()
			if hd_attr.texture.res_scale == 1.0:
				hd_attr.texture.size_override /= 2.0
				hd_attr.texture.res_scale = 2.0
			hd_attr.region.position /= 2
			hd_attr.region.size /= 2
			hd_attr.origin /= 2
			images[k] = hd_attr
	else:
		images.merge(add_images)
	return true


func get_image(image_name: StringName) -> ecImageAttr:
	return images.get(image_name)


func get_keys() -> Array[StringName]:
	return images.keys()
