extends "res://app/src/main/cpp/gui_element.gd"

const _native = preload("res://app/src/main/cpp/native-lib.gd")

signal cancled

func _on_gui_button_cancle_pressed() -> void:
	cancled.emit()


func _on_gui_button_confirm_pressed() -> void:
	_native.app_java_exit()
