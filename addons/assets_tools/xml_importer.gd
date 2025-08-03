@tool
extends EditorImportPlugin

## Curiously, unlike .bin files, .xml files are not marked for export by a
## loader (probably because it is recognized as a text file within the engine).
## Neither does a loader instruct the engine to scan .xml files for syntax
## errors. The downside of defining an importer is that it stops the editor
## from opening .xml files inside the script editor.

static var _regex_not_whitespace := RegEx.create_from_string(r"[^\s]+")

func _get_importer_name() -> String:
	return "wc2.assets.xml"


func _get_visible_name() -> String:
	return "XML"


func _get_format_version() -> int:
	return 1


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["xml", "strings"])


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
	return "tres"


func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var xml = static_load(source_file)
	if xml is not XML:
		return xml
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(xml, filename)


static func static_load(source_file: String) -> Variant:
	var parser := XMLParser.new()
	var err := parser.open(source_file)
	if err != OK:
		push_error("{0}: Failed to open {1}".format([error_string(err), source_file]))
		return err
	var xml := XML.new()
	err = _parse_section(parser, xml.nodes, source_file)
	if err == OK:
		var end_name := parser.get_node_name()
		var line := parser.get_current_line()
		if parser.read() != ERR_FILE_EOF:
			push_error("Parse Error: Unexpected closing tag in {0}: {1} on line {2}".format([source_file, end_name, line]))
			return ERR_PARSE_ERROR
	elif err != ERR_FILE_EOF:
		return err
	return xml


static func _parse_section(parser: XMLParser, section: Array[XMLNode], source_file: String) -> Error:
	var err := parser.read()
	var line := parser.get_current_line()
	while err == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var element := XMLElement.new()
				element.line = line
				element.name = parser.get_node_name()
				for i in parser.get_attribute_count():
					element.attributes[parser.get_attribute_name(i)] = parser.get_attribute_value(i)
				if not parser.is_empty():
					err = _parse_section(parser, element.inner_nodes, source_file)
					if err != OK:
						if err == ERR_FILE_EOF:
							push_error("Parse Error: Unclosed tag in {0}: {1} on line {2}".format([source_file, element.name, line]))
							return ERR_PARSE_ERROR
						else:
							return err
					var end_name := parser.get_node_name()
					if end_name != element.name:
						var end_line := parser.get_current_line()
						push_error("Parse Error: Tag mismatch in {0}: between {1} on line {2} with {3} on line {4}".format([source_file, element.name, line, end_name, end_line]))
						return ERR_PARSE_ERROR
				section.append(element)
			XMLParser.NODE_ELEMENT_END:
				return OK
			XMLParser.NODE_TEXT:
				var text := XMLText.new()
				text.line = line
				text.data = parser.get_node_data()
				if _regex_not_whitespace.search(text.data) != null:
					section.append(text)
			XMLParser.NODE_COMMENT:
				var node := XMLComment.new()
				node.line = line
				node.name = parser.get_node_name()
				section.append(node)
			XMLParser.NODE_CDATA:
				var node := XMLCData.new()
				node.line = line
				node.name = parser.get_node_name()
				section.append(node)
			XMLParser.NODE_UNKNOWN:
				var node := XMLUnknown.new()
				node.line = line
				node.name = parser.get_node_name()
				section.append(node)
		err = parser.read()
		line = parser.get_current_line()
	if err != ERR_FILE_EOF:
		push_error("{0}: Failed to parse {1} at line {2}".format([error_string(err), source_file, line]))
	return err
