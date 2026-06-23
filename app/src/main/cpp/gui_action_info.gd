extends "res://app/src/main/cpp/gui_element.gd"

@export
var info: String:
	get = get_info,
	set = set_info


func get_info() -> String:
	return $ecLabelText.text


func set_info(value: String) -> void:
	$ecLabelText.text = value
