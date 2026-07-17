extends GUIElement

@export
var info: String:
	get = get_info,
	set = set_info


func get_info() -> String:
	return $RichTextLabel.text


func set_info(value: String) -> void:
	$RichTextLabel.text = value
