@tool
extends TiXmlNode

## The top level class of this file is TiXmlDocument. Since writing methods are
## not implemented and GDScript features type inference, these is little reason
## to refer to other classed explicitly.
## 
## The bi-graph structure of the original tinyxml poorly fits the reference
## counted memory management and the resource inspector of Godot. As the
## solution, the xml files are imported as resources defined in xml*.gd files,
## and tinyxml is built on top of them as iterators.

const _TiXmlDocument = preload("res://addons/assets_tools/tinyxml.gd")
const _ecFile = preload("res://app/src/main/cpp/ec_file.gd")

static var _regex_not_whitespace := RegEx.create_from_string(r"[^\s]+")

func _init() -> void:
	_type = NodeType.DOCUMENT


func load_file(source_file: String) -> Error:
	var parser := XMLParser.new()
	var err := parser.open(source_file)
	if err != OK:
		push_error("{0}: Failed to open {1}".format([error_string(err), source_file]))
		return err
	err = _parse_section(parser, _children_resrouce, source_file)
	if err == OK:
		var end_name := parser.get_node_name()
		var line := parser.get_current_line()
		if parser.read() != ERR_FILE_EOF:
			push_error("Parse Error: Unexpected closing tag in {0}: {1} on line {2}".format([source_file, end_name, line]))
			return ERR_PARSE_ERROR
	elif err != ERR_FILE_EOF:
		return err
	return OK


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


func root_element() -> TiXmlElement:
	return first_child_element()


func previous_sibling(_find_value: String = "") -> TiXmlNode:
	return null


func next_sibling(_find_value: String = "") -> TiXmlNode:
	return null


func next_sibling_element(_find_value: String = "") -> TiXmlElement:
	return null


class TiXmlBase:
	enum {
		TIXML_SUCCESS,
		TIXML_NO_ATTRIBUTE,
		TIXML_WRONG_TYPE
	}
	
	var _row: int
	
	func row() -> int:
		return _row


class TiXmlNode:
	extends TiXmlBase
	
	enum NodeType {
		DOCUMENT,
		ELEMENT,
		COMMENT,
		UNKNOWN,
		TEXT
	}
	
	var _value: String
	var _parent: TiXmlNode
	var _index_in_parent: int
	var _children_resrouce: Array[XMLNode]
	var _type: NodeType
	
	func value() -> String:
		return _value
	
	
	func parent() -> TiXmlNode:
		return _parent
	
	
	func first_child(find_value: String = "") -> TiXmlNode:
		var i := 0
		while i < _children_resrouce.size():
			if find_value == "" or find_value == _get_child_value(i):
				return _create_child_node(i)
			i += 1
		return null
	
	
	func last_child(find_value: String = "") -> TiXmlNode:
		var i := _children_resrouce.size()
		while i > 0:
			i -= 1
			if find_value == "" or find_value == _get_child_value(i):
				return _create_child_node(i)
		return null
	
	
	func iterate_children(previous: TiXmlNode, find_value: String = "") -> TiXmlNode:
		var i := 0
		if previous != null:
			i = previous._index_in_parent
		while i < _children_resrouce.size():
			if find_value == "" or find_value == _get_child_value(i):
				return _create_child_node(i)
			i += 1
		return null
	
	
	func previous_sibling(find_value: String = "") -> TiXmlNode:
		var i := _index_in_parent
		while i > 0:
			i -= 1
			if find_value == "" or find_value == _parent._get_child_value(i):
				return _parent._create_child_node(i)
		return null
	
	
	func next_sibling(find_value: String = "") -> TiXmlNode:
		var i := _index_in_parent + 1
		while i < _parent._children_resrouce.size():
			if find_value == "" or find_value == _parent._get_child_value(i):
				return _parent._create_child_node(i)
			i += 1
		return null
	
	
	func next_sibling_element(find_value: String = "") -> TiXmlElement:
		var i := _index_in_parent + 1
		while i < _parent._children_resrouce.size():
			if _parent._children_resrouce[i] is XMLElement and find_value == "" or find_value == _parent._get_child_value(i):
				return _parent._create_child_node(i) as TiXmlElement
			i += 1
		return null
	
	
	func first_child_element(find_value: String = "") -> TiXmlElement:
		var i := 0
		while i < _children_resrouce.size():
			if _children_resrouce[i] is XMLElement and find_value == "" or find_value == _get_child_value(i):
				return _create_child_node(i) as TiXmlElement
			i += 1
		return null
	
	
	func type() -> NodeType:
		return _type
	
	
	func get_document() -> _TiXmlDocument:
		var document := self
		while document._parent != null:
			document = document._parent
		return document as _TiXmlDocument
	
	
	func no_children() -> bool:
		return _children_resrouce.is_empty()
	
	
	func to_document() -> _TiXmlDocument:
		return self as _TiXmlDocument
	
	
	func to_element() -> TiXmlElement:
		return self as TiXmlElement
	
	
	func to_comment() -> TiXmlComment:
		return self as TiXmlComment
	
	
	func to_unknown() -> TiXmlUnknown:
		return self as TiXmlUnknown
	
	
	func to_text() -> TiXmlText:
		return self as TiXmlText
	
	
	# Avoid creating a node only to check its value
	func _get_child_value(i: int) -> String:
		var child_resource = _children_resrouce[i]
		if child_resource is XMLElement:
			return child_resource.name
		elif child_resource is XMLComment:
			return child_resource.name
		elif child_resource is XMLCData:
			return child_resource.name
		elif child_resource is XMLUnknown:
			return child_resource.name
		elif child_resource is XMLText:
			return child_resource.data
		else:
			return ""
	
	
	func _create_child_node(i: int) -> TiXmlNode:
		var child: TiXmlNode = null
		var child_resource = _children_resrouce[i]
		if child_resource is XMLElement:
			child = TiXmlElement.new()
			child._value = child_resource.name
			child._type = NodeType.ELEMENT
			child._resource = child_resource
			child._children_resrouce = child_resource.inner_nodes
		elif child_resource is XMLComment:
			child = TiXmlComment.new()
			child._value = child_resource.name
			child._type = NodeType.COMMENT
		elif child_resource is XMLCData:
			child = TiXmlText.new()
			child._value = child_resource.name
			child._type = NodeType.TEXT
			child._is_cdata = true
		elif child_resource is XMLUnknown:
			child = TiXmlUnknown.new()
			child._value = child_resource.name
			child._type = NodeType.UNKNOWN
		elif child_resource is XMLText:
			child = TiXmlText.new()
			child._value = child_resource.data
			child._type = NodeType.TEXT
			child._is_cdata = false
		else:
			return null
		child._row = child_resource.line
		child._parent = self
		child._index_in_parent = i
		return child


class TiXmlElement:
	extends TiXmlNode
	
	var _resource: XMLElement
	
	func attribute(name: String, p: Array = []) -> String:
		if name not in _resource.attributes:
			return ""
		var s = _resource.attributes[name]
		if p.size() != 0:
			if p[0] is int and s.is_valid_int():
				p[0] = s.to_int()
			elif p[0] is float and s.is_valid_float():
				p[0] = s.to_float()
		return s
	
	
	func query_int_attribute(name: String, p: Array[int]) -> int:
		if name not in _resource.attributes:
			return TIXML_NO_ATTRIBUTE
		var s = _resource.attributes[name]
		if not s.is_valid_int():
			return TIXML_WRONG_TYPE
		p.append(s.to_int())
		return TIXML_SUCCESS
	
	
	func query_float_attribute(name: String, p: Array[float]) -> int:
		if name not in _resource.attributes:
			return TIXML_NO_ATTRIBUTE
		var s = _resource.attributes[name]
		if not s.is_valid_float():
			return TIXML_WRONG_TYPE
		p.append(s.to_float())
		return TIXML_SUCCESS
	
	
	func first_attribute() -> TiXmlAttribute:
		if _resource.attributes.size() == 0:
			return null
		var attr := TiXmlAttribute.new()
		attr._row = _row
		attr._keys = _resource.attributes.keys()
		attr._values = _resource.attributes
		attr._index = 0
		return attr
	
	
	func last_attribute() -> TiXmlAttribute:
		if _resource.attributes.size() == 0:
			return null
		var attr := TiXmlAttribute.new()
		attr._row = _row
		attr._keys = _resource.attributes.keys()
		attr._values = _resource.attributes
		attr._index = _resource.attributes.size() - 1
		return attr
	
	
	func get_text() -> String:
		if _children_resrouce.size() > 0:
			if _children_resrouce[0] is XMLText:
				return _children_resrouce[0].data
			elif _children_resrouce[0] is XMLCData:
				return _children_resrouce[0].name
		return ""


class TiXmlComment:
	extends TiXmlNode


class TiXmlUnknown:
	extends TiXmlNode


class TiXmlText:
	extends TiXmlNode
	
	var _is_cdata: bool
	
	func cdata() -> bool:
		return _is_cdata


class TiXmlAttribute:
	extends TiXmlBase
	
	var _keys: Array[String]
	var _values: Dictionary[String, String]
	var _index: int
	
	func name() -> String:
		return _keys[_index]
	
	
	func value() -> String:
		return _values[name()]
	
	
	func int_value() -> int:
		return value().to_int()
	
	
	func float_value() -> float:
		return value().to_float()
	
	
	func query_int_value(p: Array[int]) -> int:
		var s := value()
		if not s.is_valid_int():
			return TIXML_WRONG_TYPE
		p.append(s.to_int())
		return TIXML_SUCCESS
	
	
	func query_float_value(p: Array[float]) -> int:
		var s := value()
		if not s.is_valid_float():
			return TIXML_WRONG_TYPE
		p.append(s.to_float())
		return TIXML_SUCCESS
	
	
	func next() -> TiXmlAttribute:
		var next_index := _index + 1
		if next_index >= _keys.size():
			return null
		var attr := TiXmlAttribute.new()
		attr._row = _row
		attr._keys = _keys
		attr._values = _values
		attr._index = next_index
		return attr
		
		
	func previous() -> TiXmlAttribute:
		var previous_index := _index - 1
		if previous_index < 0:
			return null
		var attr := TiXmlAttribute.new()
		attr._row = _row
		attr._keys = _keys
		attr._values = _values
		attr._index = previous_index
		return attr
