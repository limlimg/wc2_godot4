@tool
extends GUIButton

@export
var army: CArmy

func _process(_delta: float) -> void:
	$UIArmy.queue_redraw()


func _on_ui_army_draw() -> void:
	if army == null or army.def == null:
		return
	g_GameRes.render_ui_army($UIArmy.get_canvas_item(), army.country.name, 0.0, 0.0, army.def.id, false, army.strength, army.get_max_strength(), army.movement, army.cards, army.level if army.cards & (1<<3) == 0 else army.country.get_commander_level())
