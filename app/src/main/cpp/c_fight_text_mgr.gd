extends Node2D

func add_text(x: float, y: float, text: String, color: Color) -> void:
	var node := $Prototype/CFightText.duplicate()
	node.position = Vector2(x, y)
	node.set_text(text)
	node.set_color(color)
	$Live.add_child(node)
	node.hidden.connect(_remove.bind(node))


func release() -> void:
	$Prototype/CFightText.theme = null
	for c in $Live.get_children():
		_remove(c)


func _remove(node: Node) -> void:
	$Live.remove_child(node)
	node.queue_free()
