extends "res://game_res_render/ui_attack_army.gd"

func _draw() -> void:
	ecGraphics.instance().render_begin(self)
	g_GameRes.render_ui_defend_army(country, 0.0, 0.0, id, durability, max_durability, movement, cards, level, alliance, ai)
	ecGraphics.instance().render_end()
