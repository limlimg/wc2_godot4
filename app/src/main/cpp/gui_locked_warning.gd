extends "res://app/src/main/cpp/gui_element.gd"

const _native = preload("res://app/src/main/cpp/native-lib.gd")

signal pressed

func _ready() -> void:
	init()


func init() -> void:
	$CenterContainer/GUIRect/Control/GUIRect2/ecText.set_text(_native.g_string_table.get_string(&"locked warning"))


func _on_button_pressed() -> void:
	pressed.emit()
