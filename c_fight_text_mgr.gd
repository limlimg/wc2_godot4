extends Control

var _texts: Array[Label]

func add_text(x: float, y: float, text: String, color: Color) -> void:
	if self == g_FightTextMgr:
		var scene_node = get_tree().get_first_node_in_group(&"g_FightTextMgr")
		if scene_node != null:
			scene_node.add_text(x, y, text, color)
			return
	var node = $Num2/CFightText.create_instance()
	node.position = Vector2(x, y)
	node.set_text(text)
	node.set_color(color)
	node.hidden.connect(_remove.bind(node))
	_texts.append(node)


func release() -> void:
	if self == g_FightTextMgr:
		var scene_node = get_tree().get_first_node_in_group(&"g_FightTextMgr")
		if scene_node != null:
			scene_node.release()
	while not _texts.is_empty():
		_remove(_texts[-1])


func _remove(node: Node) -> void:
	_texts[_texts.find(node)] = _texts[-1]
	_texts.pop_back()
	node.queue_free()
