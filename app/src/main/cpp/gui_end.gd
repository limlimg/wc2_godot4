extends "res://app/src/main/cpp/gui_element.gd"

@export
var campaign: int:
	set(value):
		if value != campaign:
			campaign = value
			if is_node_ready():
				init()


func _ready() -> void:
	init()


func init() -> void:
	match campaign:
		0:
			$VictroyBg.texture = load("res://app/src/main/cpp/resources/assets/texture/victorybg_axis.tres")
			$TextVictroy/Label.text = "victory axis"
		1:
			$VictroyBg.texture = load("res://app/src/main/cpp/resources/assets/texture/victorybg_allies.tres")
			$TextVictroy/Label.text = "victory allies"
		2:
			$VictroyBg.texture = load("res://app/src/main/cpp/resources/assets/texture/victorybg_wto.tres")
			$TextVictroy/Label.text = "victory wto"
		3:
			$VictroyBg.texture = load("res://app/src/main/cpp/resources/assets/texture/victorybg_nato.tres")
			$TextVictroy/Label.text = "victory nato"


func _on_gui_button_back_pressed() -> void:
	back_pressed.emit()
