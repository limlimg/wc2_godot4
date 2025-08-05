class_name XMLElement
extends XMLNode

@export
var name: String

@export
var attributes: Dictionary[String, String]

@export
var inner_nodes: Array[XMLNode]

func _init() -> void:
	type = XMLParser.NODE_ELEMENT
