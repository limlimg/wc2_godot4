@tool
extends EditorImportPlugin

const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")
const _ecTextureRes = preload("res://app/src/main/cpp/imported_containers/ec_texture_res.gd")
const _ecTextureRect = preload("res://app/src/main/cpp/ec_texture_rect.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml.texture"


func _get_visible_name() -> String:
	return "ecTextureRes"


func _get_format_version() -> int:
	return 1


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["xml"])


func _get_priority() -> float:
	return 1.0


func _get_import_order() -> int:
	return 2


func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	return []


func _get_option_visibility(_path: String, _option_name: StringName, _options: Dictionary) -> bool:
	return true


func _get_preset_count() -> int:
	return 0


func _get_preset_name(preset_index: int) -> String:
	return ""


func _get_resource_type() -> String:
	return "Resource"


func _get_save_extension() -> String:
	return "res"


func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var doc := _TiXmlDocument.new()
	var err := doc.load_file(source_file)
	if err != OK:
		return err
	var xml_root := doc.first_child_element("Texture")
	if xml_root == null:
		push_error("Parse Error: Failed to find <Texture> in {0}".format([source_file]))
		return ERR_PARSE_ERROR
	var res_texture := _ecTextureRes.new()
	var texture_name := xml_root.attribute("name")
	if texture_name == "":
		push_error("Parse Error: Element does not have valid \"name\" attibute on line {0} of {1}".format([xml_root.row() + 1, source_file]))
		return ERR_PARSE_ERROR
	var source_dict := source_file.substr(0, source_file.rfind('/') + 1) 
	var texture_path := source_dict + texture_name
	if load(texture_path) as Texture2D == null:
		push_error("Error: failed to validate texture {0} for {1}".format([texture_name, source_file]))
		return FAILED
	res_texture.texture_name = texture_name
	var xml_images := doc.first_child_element("Images")
	if xml_images == null:
		push_error("Parse Error: Failed to find <Images> in {0}".format([source_file]))
		return ERR_PARSE_ERROR
	var xml_image := xml_images.first_child_element()
	while xml_image != null:
		var name := xml_image.attribute("name")
		if name == "":
			push_error("Parse Error: Element does not have valid \"name\" attibute on line {0} of {1}".format([xml_image.row() + 1, source_file]))
			return ERR_PARSE_ERROR
		var p: Array[float] = []
		var x := 0.0
		if xml_image.query_float_attribute("x", p) == xml_image.TIXML_SUCCESS:
			x = p.pop_back()
		var y := 0.0
		if xml_image.query_float_attribute("y", p) == xml_image.TIXML_SUCCESS:
			y = p.pop_back()
		var w := 1.0
		if xml_image.query_float_attribute("w", p) == xml_image.TIXML_SUCCESS:
			w = p.pop_back()
		var h := 1.0
		if xml_image.query_float_attribute("h", p) == xml_image.TIXML_SUCCESS:
			h = p.pop_back()
		var refx := 0.0
		if xml_image.query_float_attribute("refx", p) == xml_image.TIXML_SUCCESS:
			refx = p.pop_back()
		var refy := 0.0
		if xml_image.query_float_attribute("refy", p) == xml_image.TIXML_SUCCESS:
			refy = p.pop_back()
		var res_image := _ecTextureRect.new()
		res_image.x = x
		res_image.y = y
		res_image.w = w
		res_image.h = h
		res_image.refx = refx
		res_image.refy = refy
		res_texture.images[name] = res_image
		xml_image = xml_image.next_sibling_element()
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res_texture, filename)
