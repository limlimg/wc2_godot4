extends "res://app/src/main/cpp/scene_system_resource/game_res/ui_attack_army.gd"

func _draw() -> void:
	_ecGraphics.instance().render_begin(self)
	g_GameRes.render_ui_defend_army(country, 0.0, 0.0, id, durability, max_durability, movement, cards, level, alliance, ai)
	_ecGraphics.instance().render_end()
