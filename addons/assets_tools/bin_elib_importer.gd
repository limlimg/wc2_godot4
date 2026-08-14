@tool
extends EditorImportPlugin

func _get_importer_name() -> String:
	return "wc2.assets.bin.elib"


func _get_visible_name() -> String:
	return "ecLibraryData"


func _get_format_version() -> int:
	return 1


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["bin"])


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
	var file := FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		var err := FileAccess.get_open_error()
		push_error("{0}: Failed to open {1}".format([error_string(err), source_file]))
		return err
	if file.get_length() < 28:
		push_error("Failed to import {0}: File too small".format([source_file]))
		return ERR_PARSE_ERROR
	var magic := file.get_32()
	var version := file.get_32()
	if magic != 0x454C4942 or version != 2:
		push_error("Failed to import {0}: Invalid header".format([source_file]))
		return ERR_PARSE_ERROR
	var expected_file_length := file.get_32() + 8
	var file_length := file.get_length()
	if file_length < expected_file_length:
		push_error("Failed to import {0}: Unexpected file length: expected at least {1}, got {2}".format([source_file, expected_file_length, file_length]))
		return ERR_PARSE_ERROR
	var section_position := file.get_16()
	var section_count := file.get_16()
	var frame_rate := file.get_float()
	if frame_rate == 0.0:
		push_error("Failed to import {0}: Frame rate cannot be 0.0".format([source_file]))
		return ERR_PARSE_ERROR
	var item_position: int
	var item_count: int
	var item_name_position: int
	var item_name_size: int
	var layer_position: int
	var layer_count: int
	var frame_position: int
	var frame_count: int
	var element_position: int
	var element_count: int
	for i in section_count:
		if section_position >= file_length:
			push_error("Failed to import {0}: Unexpected end of file at {1}".format([source_file, section_position]))
			return ERR_PARSE_ERROR
		file.seek(section_position)
		var section_magic := file.get_32()
		var section_size := file.get_32()
		match section_magic:
			0x454C4542:
				element_count = file.get_32()
				if section_size < element_count * 48:
					push_error("Failed to import {0}: Section too small at {1}, expected at least {2}, got {3}".format([source_file, section_position, element_count * 48, section_size]))
					return ERR_PARSE_ERROR
				element_position = section_position + 16
			0x46524D42:
				frame_count = file.get_32()
				if section_size < element_count * 12:
					push_error("Failed to import {0}: Section too small at {1}, expected at least {2}, got {3}".format([source_file, section_position, frame_count * 12, section_size]))
					return ERR_PARSE_ERROR
				frame_position = section_position + 16
			0x4C415942:
				layer_count = file.get_32()
				if section_size < layer_count * 8:
					push_error("Failed to import {0}: Section too small at {1}, expected at least {2}, got {3}".format([source_file, section_position, layer_count * 8, section_size]))
					return ERR_PARSE_ERROR
				layer_position = section_position + 16
			0x49544D42:
				item_count = file.get_32()
				if section_size < item_count * 56:
					push_error("Failed to import {0}: Section too small at {1}, expected at least {2}, got {3}".format([source_file, section_position, item_count * 56, section_size]))
					return ERR_PARSE_ERROR
				item_position = section_position + 16
			0x53545242:
				item_name_size = section_size
				item_name_position = section_position + 12
			_:
				push_error("Failed to import {0}: Unrecognized section at {1}".format([source_file, section_position]))
				return ERR_PARSE_ERROR
		section_position += section_size
	file.seek(item_name_position)
	var item_name_buffer := file.get_buffer(item_name_size)
	var res := ecLibraryData.new()
	var items: Array[ecItemData]
	var element_sub_item: Dictionary[ecElementData, int]
	for i in item_count:
		file.seek(item_position)
		var item: ecItemData
		var item_shape_index := file.get_32()
		var item_name_offset := file.get_32()
		var item_name_byte := item_name_buffer.slice(item_name_offset, item_name_buffer.find(0, item_name_offset))
		var item_name = item_name_byte.get_string_from_utf8()
		var shape_position = Vector2(file.get_float(), file.get_float())
		file.get_32() # unknown or no longer used
		file.get_32() # unknown or no longer used
		if file.get_32() != 0:
			assert(item_shape_index == i)
			item = ecShapeData.new()
			#shape_index[item] = item_shape_index
			item.shape_position = shape_position
			file.get_32() # unknown or no longer used
		else:
			item = ecMotionData.new()
			item.duration = file.get_32()
		items.append(item)
		item.item_name = item_name
		var item_layer_created := file.get_32()
		var item_frame_to_create := file.get_32()
		var item_element_to_create := file.get_32()
		file.get_32() # unknown or no longer used
		file.get_32() # unknown or no longer used
		file.get_32() # unknown or no longer used
		for j in item_layer_created:
			file.seek(layer_position)
			var layer := ecLayerData.new()
			var layer_frame_created = file.get_32()
			file.get_32() # unknown or no longer used
			for k in layer_frame_created:
				file.seek(frame_position)
				var frame := ecFrameData.new()
				frame.start_tick = file.get_32()
				var frame_element_created := file.get_32()
				file.get_32() # unknown or no longer used
				for l in frame_element_created:
					file.seek(element_position)
					var element := ecElementData.new()
					var xx := file.get_float()
					var yx := file.get_float()
					var xy := file.get_float()
					var yy := file.get_float()
					element.transform = Transform2D(Vector2(xx, yx), Vector2(xy, yy), Vector2(file.get_float(), file.get_float()))
					element.alpha = file.get_float()
					element.initial_frame = file.get_32()
					element.loop = file.get_32()
					file.get_32() # unknown or no longer used
					file.get_32() # unknown or no longer used
					element_sub_item[element] = file.get_32()
					frame.elements.append(element)
					element_position += 48
				item_element_to_create -= frame_element_created
				layer.frames.append(frame)
				frame_position += 12
			item_frame_to_create -= layer_frame_created
			if item is ecMotionData:
				item.layers.append(layer)
			layer_position += 8
		assert(item_element_to_create == 0)
		assert(item_frame_to_create == 0)
		if item is ecMotionData:
			res.motion_items[item.item_name] = item
		elif item is ecShapeData:
			res.shape_items[item.item_name] = item
		item_position += 56
	for i in res.motion_items.values():
		if _check_cycle(i, items, element_sub_item, source_file):
			return ERR_PARSE_ERROR
	res.frame_rate = frame_rate
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res, filename)


func _check_cycle(item: ecMotionData, items: Array[ecItemData], element_sub_item: Dictionary[ecElementData, int], source_file: String, stack: Array[ecMotionData] = []) -> bool:
	stack.push_back(item)
	for l in item.layers:
		for f in l.frames:
			for e in f.elements:
				if element_sub_item[e] == 0xFFFFFFFF:
					continue
				if element_sub_item[e] >= items.size():
					push_error("Failed to import {0}: Invalid item index {1}".format([source_file, element_sub_item[e]]))
					return true
				var sub_item := items[element_sub_item[e]]
				if sub_item is ecMotionData:
					if stack.has(sub_item):
						push_error("Failed to import {0}: Cyclic reference to item '{1}'".format([source_file, sub_item.item_name]))
						return true
					if _check_cycle(sub_item, items, element_sub_item, source_file, stack):
						return true
				e.sub_item = sub_item
	stack.pop_back()
	return false
