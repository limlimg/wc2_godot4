class_name XMLCData
extends XMLNode

@export
var name: String

func _init() -> void:
	type = XMLParser.NODE_CDATA
