class_name XML
extends Resource

## The original code uses tinyxml to parse and represent an xml document, whose
## structure (double linked graph) and usage poorly fits the reference counting
## memory management and the resource inspector panel. Therefore, this custom
## resource type is created after Godot's XMLParser to represent imported xml
## files.

@export
var nodes: Array[XMLNode]
