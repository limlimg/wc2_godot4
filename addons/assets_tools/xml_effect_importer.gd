@tool
extends EditorImportPlugin

const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")

func _get_importer_name() -> String:
	return "wc2.assets.xml.effect"


func _get_visible_name() -> String:
	return "ecEffectRes"


func _get_format_version() -> int:
	return 1


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["xml"])


func _get_priority() -> float:
	return 1.0


func _get_import_order() -> int:
	return 1


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
	var xml_root := doc.first_child_element("effect")
	if xml_root == null:
		push_error("Parse Error: Failed to find <effect> in {0}".format([source_file]))
		return ERR_PARSE_ERROR
	var res_effect := ecEffectRes.new()
	var xml_emitter := xml_root.first_child_element()
	while xml_emitter != null:
		var res_emitter := ecEmitterAttr.new()
		var color_min := Color.WHITE
		var color_max := Color.WHITE
		var pf: Array[float]
		var pi: Array[int]
		if xml_emitter.query_float_attribute("life", pf) == xml_emitter.TIXML_SUCCESS:
			res_emitter.emitter_life = pf.pop_back()
		if xml_emitter.query_float_attribute("offsetx", pf) == xml_emitter.TIXML_SUCCESS:
			res_emitter.offset.x = pf.pop_back()
		if xml_emitter.query_float_attribute("offsety", pf) == xml_emitter.TIXML_SUCCESS:
			res_emitter.offset.y = pf.pop_back()
		var xml_param := xml_emitter.first_child_element()
		while xml_param != null:
			match xml_param.attribute("name"):
				"settings":
					res_emitter.settings_mode = 1 if xml_param.attribute("mode") == "once" else 0
					match xml_param.attribute("type"):
						"line":
							res_emitter.settings_type = 1
							if xml_param.query_float_attribute("len", pf) == xml_param.TIXML_SUCCESS:
								res_emitter.settings_param_1 = pf.pop_back()
						"area":
							res_emitter.settings_type = 2
							if xml_param.query_float_attribute("width", pf) == xml_param.TIXML_SUCCESS:
								res_emitter.settings_param_1 = pf.pop_back()
							if xml_param.query_float_attribute("height", pf) == xml_param.TIXML_SUCCESS:
								res_emitter.settings_param_2 = pf.pop_back()
						"ellipse":
							res_emitter.settings_type = 3
							if xml_param.query_float_attribute("r", pf) == xml_param.TIXML_SUCCESS:
								res_emitter.settings_param_1 = pf.pop_back()
						_:
							res_emitter.settings_type = 0
				"image":
					res_emitter.image_file = xml_param.attribute("file")
					res_emitter.image_blend = 1 if xml_param.attribute("blend") == "add" else 0
					if xml_param.query_float_attribute("width", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.image_width = pf.pop_back()
					if xml_param.query_float_attribute("height", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.image_height = pf.pop_back()
				"life":
					if xml_param.query_float_attribute("min", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.particle_life_min = pf.pop_back()
					if xml_param.query_float_attribute("max", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.particle_life_max = pf.pop_back()
				"angle":
					if xml_param.query_float_attribute("min", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.angle_min = deg_to_rad(pf.pop_back())
					if xml_param.query_float_attribute("max", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.angle_max = deg_to_rad(pf.pop_back())
				"rotangle":
					if xml_param.attribute("type") == "regular":
						res_emitter.rot_angle_type = 1.0
					else:
						res_emitter.rot_angle_type = 0.0
						if xml_param.query_float_attribute("min", pf) == xml_param.TIXML_SUCCESS:
							res_emitter.rot_angle_min = deg_to_rad(pf.pop_back())
						if xml_param.query_float_attribute("max", pf) == xml_param.TIXML_SUCCESS:
							res_emitter.rot_angle_max = deg_to_rad(pf.pop_back())
				"speed":
					if xml_param.query_float_attribute("min", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.speed_min = pf.pop_back()
					if xml_param.query_float_attribute("max", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.speed_max = pf.pop_back()
				"gravity":
					if xml_param.query_float_attribute("min", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.gravity_min = pf.pop_back()
					if xml_param.query_float_attribute("max", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.gravity_max = pf.pop_back()
				"scale":
					if xml_param.query_float_attribute("min", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.scale_min = pf.pop_back()
					if xml_param.query_float_attribute("max", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.scale_max = pf.pop_back()
				"rotspeed":
					if xml_param.query_float_attribute("min", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.rot_speed_min = pf.pop_back()
					if xml_param.query_float_attribute("max", pf) == xml_param.TIXML_SUCCESS:
						res_emitter.rot_speed_max = pf.pop_back()
				"r":
					if xml_param.query_int_attribute("min", pi) == xml_param.TIXML_SUCCESS:
						color_min.r8 = pi.pop_back()
					if xml_param.query_int_attribute("max", pi) == xml_param.TIXML_SUCCESS:
						color_max.r8 = pi.pop_back()
				"g":
					if xml_param.query_int_attribute("min", pi) == xml_param.TIXML_SUCCESS:
						color_min.g8 = pi.pop_back()
					if xml_param.query_int_attribute("max", pi) == xml_param.TIXML_SUCCESS:
						color_max.g8 = pi.pop_back()
				"b":
					if xml_param.query_int_attribute("min", pi) == xml_param.TIXML_SUCCESS:
						color_min.b8 = pi.pop_back()
					if xml_param.query_int_attribute("max", pi) == xml_param.TIXML_SUCCESS:
						color_max.b8 = pi.pop_back()
				"a":
					if xml_param.query_int_attribute("min", pi) == xml_param.TIXML_SUCCESS:
						color_min.a8 = pi.pop_back()
					if xml_param.query_int_attribute("max", pi) == xml_param.TIXML_SUCCESS:
						color_max.a8 = pi.pop_back()
				"timetrack":
					var xml_track := xml_param.first_child_element()
					var time_track := res_emitter.time_track
					time_track.max_domain = 0.0
					time_track.max_value = 0.0
					while xml_track != null:
						if xml_track.query_float_attribute("time", pf) == xml_track.TIXML_SUCCESS\
								and xml_track.query_int_attribute("quantity", pi) == xml_track.TIXML_SUCCESS:
							var time := pf.pop_back()
							var quantity := pi.pop_back()
							if time < time_track.min_domain:
								time_track.min_domain = time
							if time > time_track.max_domain:
								time_track.max_domain = time
							if quantity < time_track.min_value:
								time_track.min_value = quantity
							if quantity > time_track.max_value:
								time_track.max_value = quantity
							time_track.add_point(Vector2(time, quantity), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
						xml_track = xml_track.next_sibling_element()
				"lifetrack":
					var xml_track := xml_param.first_child_element()
					var speed_track := res_emitter.life_track_speed
					var gravity_track := res_emitter.life_track_gravity
					var scale_track := res_emitter.life_track_scale
					var rot_speed_track := res_emitter.life_track_rot_speed
					while xml_track != null:
						if xml_track.query_float_attribute("life", pf) == xml_track.TIXML_SUCCESS:
							var life := pf.pop_back()
							if xml_track.query_float_attribute("speed", pf) == xml_track.TIXML_SUCCESS:
								var value := pf.pop_back()
								if value < speed_track.min_value:
									speed_track.min_value = value
								if value > speed_track.max_value:
									speed_track.max_value = value
								speed_track.add_point(Vector2(life, value), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
							if xml_track.query_float_attribute("gravity", pf) == xml_track.TIXML_SUCCESS:
								var value := pf.pop_back()
								if value < gravity_track.min_value:
									gravity_track.min_value = value
								if value > gravity_track.max_value:
									gravity_track.max_value = value
								gravity_track.add_point(Vector2(life, value), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
							if xml_track.query_float_attribute("scale", pf) == xml_track.TIXML_SUCCESS:
								var value := pf.pop_back()
								if value < scale_track.min_value:
									scale_track.min_value = value
								if value > scale_track.max_value:
									scale_track.max_value = value
								scale_track.add_point(Vector2(life, value), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
							if xml_track.query_float_attribute("rotspeed", pf) == xml_track.TIXML_SUCCESS:
								var value := pf.pop_back()
								if value < rot_speed_track.min_value:
									rot_speed_track.min_value = value
								if value > rot_speed_track.max_value:
									rot_speed_track.max_value = value
								rot_speed_track.add_point(Vector2(life, value), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
							if xml_track.query_float_attribute("a", pf) == xml_track.TIXML_SUCCESS\
									and xml_track.query_float_attribute("b", pf) == xml_track.TIXML_SUCCESS\
									and xml_track.query_float_attribute("g", pf) == xml_track.TIXML_SUCCESS\
									and xml_track.query_float_attribute("r", pf) == xml_track.TIXML_SUCCESS:
								res_emitter.life_track_color.add_point(life, Color(pf.pop_back(), pf.pop_back(), pf.pop_back(), pf.pop_back()))
						xml_track = xml_track.next_sibling_element()
			xml_param = xml_param.next_sibling_element()
		res_emitter.color_range.add_point(0.0, color_min)
		res_emitter.color_range.add_point(1.0, color_max)
		res_emitter.color_range.remove_point(1)
		res_emitter.color_range.remove_point(0)
		res_emitter.life_track_color.remove_point(1)
		res_emitter.life_track_color.remove_point(0)
		res_effect.emitter.append(res_emitter)
		xml_emitter = xml_emitter.next_sibling_element()
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res_effect, filename)
