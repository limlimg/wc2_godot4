@tool
class_name ecTextureloader
extends ResourceFormatLoader

## The original game code uses different variants of some textures according to
## the aspect ratio and the value of g_contentscalefactor, which is not the
## recommended practice in Godot. This loader wraps this by adding suffixes to
## the name of the texture file to load, and loading the texture with the
## modified name if it exists. 
## 
## The following suffix is added according to the content size in
## ecGraphics::Instance():
## 1024x768	_iPad
## 640x320	-640h	(never used)
## 568x320	-568h
## 534x320	-534h
## 512x320	-512h	(never used)
## 
## (The above rule is best demostrated by GUITutorails::LoadScript)
## 
## After the above suffix, if g_contentscalefactor equals 2.0, "@2x" is added
## for high-resolution texture.
## 
## (The above rule is from ecTextureLoad in the original code.)
## 
## This loader is also responsible for wrapping "@2x" in ecTexture.

const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _ecTexture := preload("res://app/src/main/cpp/ec_texture.gd")
const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")
const _HD_SUFFIX = "@2x"
const CONTENT_SIZE_SUFFIX = ["_iPad", "-640h", "-568h", "-534h", "-512h"]

func _init() -> void:
	ResourceLoader.add_resource_format_loader(self, true)


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["ctex"])


#func _handles_type(type: StringName) -> bool:
	#return type == &"Texture2D" or type == &"Resource"
#
#
func _recognize_path(path: String, _type: StringName) -> bool:
	for ext in _get_recognized_extensions():
		if path.ends_with(ext):
			return true
	return false


#func _exists(path: String) -> bool:
	#pass
#
#
func _get_resource_type(path: String) -> String:
	if _recognize_path(path, &"Texture2D"):
		return "Texture2D"
	return ""


func _get_resource_script_class(path: String) -> String:
	if _recognize_path(path, &"Texture2D") and _is_2x_path(path):
		return "ecTexture"
	return ""


#func _get_dependencies(path: String, add_types: bool) -> PackedStringArray:
	#pass
#
#
#func _get_classes_used(path: String) -> PackedStringArray:
	#pass
#
#
#func _get_resource_uid(path: String) -> int:
	#pass
#
#
#func _rename_dependencies(path: String, renames: Dictionary) -> Error:
	#pass
#
#
func _load(path: String, original_path: String, _use_sub_threads: bool, _cache_mode: int) -> Variant:
	var s := original_path
	var i := s.rfind('.')
	if s.substr(i - 3, 3) == _HD_SUFFIX:
		i -= 3
		s = s.erase(i, 3)
	if s.substr(i - 5, 5) in CONTENT_SIZE_SUFFIX:
		i -= 5
		s = s.erase(i, 5)
	if not Engine.is_editor_hint():
		if _native.g_content_scale_factor == 2.0:
			var path_2x = s.insert(i, _HD_SUFFIX)
			var path_suffix_2x := insert_suffix(path_2x, i)
			if path_suffix_2x == original_path:
				return _load_2x(path)
			elif ResourceLoader.exists(path_suffix_2x):
				return load(path_suffix_2x)
		var path_suffix := insert_suffix(s, i)
		if path_suffix == original_path:
			return _load_texture(path)
		elif ResourceLoader.exists(path_suffix):
			return load(path_suffix)
	if _is_2x_path(original_path) or _native.g_content_scale_factor == 2.0:
		var path_2x = s.insert(i, _HD_SUFFIX)
		if path_2x == original_path:
				return _load_2x(path)
		elif ResourceLoader.exists(path_2x):
				return load(path_2x)
	return _load_texture(path)


func _is_2x_path(original_path: String) -> bool:
	return original_path.substr(original_path.rfind(".") - 3, 3) == _HD_SUFFIX


static func insert_suffix(path: String, position: int) -> String:
	var graphics := _ecGraphics.instance()
	if graphics.content_scale_size_mode == 3:
		return path.insert(position, CONTENT_SIZE_SUFFIX[0])
	else:
		var w := graphics.orientated_content_scale_width
		if w > 568.0:
			return path.insert(position, CONTENT_SIZE_SUFFIX[1])
		elif w > 534.0:
			return path.insert(position, CONTENT_SIZE_SUFFIX[2])
		elif w == 534.0:
			return path.insert(position, CONTENT_SIZE_SUFFIX[3])
		elif w == 512.0:
			return path.insert(position, CONTENT_SIZE_SUFFIX[4])
		else:
			return path


func _load_2x(path: String) -> Variant:
	var texture := _ecTexture.new()
	texture.texture = CompressedTexture2D.new()
	var err: Error = texture.texture.load(path)
	if err != OK:
		return err
	texture.size_override = texture.texture.get_size() / 2.0
	texture.res_scale = 1.0
	return texture


func _load_texture(path: String) -> Variant:
	var texture := CompressedTexture2D.new()
	var err: Error = texture.load(path)
	if err != OK:
		return err
	return texture
