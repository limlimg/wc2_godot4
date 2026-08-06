extends Control

var _texts: Array[Label]

func init() -> void:
	if self == g_FightTextMgr:
		var scene_node = get_tree().get_first_node_in_group(&"g_FightTextMgr")
		if scene_node != null:
			scene_node.init()
			return
	if EC2dAppDelegate.g_content_scale_factor == 2.0:
		$Num2.init("num2_hd.fnt", true)
	else:
		$Num2.init("num2.fnt", false)


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
	_texts.append(node)


func release() -> void:
	if self == g_FightTextMgr:
		var scene_node = get_tree().get_first_node_in_group(&"g_FightTextMgr")
		if scene_node != null:
			scene_node.release()
			return
	$Num2.release()
	for i in _texts:
		i.queue_free()
	_texts.clear()


func update(delta: float) -> void:
	var i := 0
	while i < _texts.size():
		if _texts[i].update(delta):
			i += 1
		else:
			_texts[i].queue_free()
			_texts.remove_at(i)
