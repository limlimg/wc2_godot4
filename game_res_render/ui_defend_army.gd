extends "res://game_res_render/ui_attack_army.gd"

func _draw() -> void:
	g_GameRes.render_ui_defend_army(get_canvas_item(), country, 0.0, 0.0, id, durability, max_durability, movement, cards, level, alliance, ai)
