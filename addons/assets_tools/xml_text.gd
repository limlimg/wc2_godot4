class_name XMLText
extends XMLNode

@export
var data: String

func _init() -> void:
	type = XMLParser.NODE_TEXT
