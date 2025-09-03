class_name XMLComment
extends XMLNode

@export
var name: String

func _init() -> void:
	type = XMLParser.NODE_COMMENT
