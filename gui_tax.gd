extends GUIElement

const _INSTALLATION_STAMP = [
	"stamp_fortress.png",
	"stamp_wire.png",
	"stamp_aagun.png",
	"stamp_radar.png"
]

@export
var area: int

@export
var money := 0:
	set = set_money

@export
var industry := 0:
	set = set_industry

func set_area(id: int) -> void:
	area = id
	var res := texture_res
	if res == null:
		res = s_texture_res
	set_money(g_Scene.get_area(id).get_real_tax())
	set_industry(g_Scene.get_area(id).get_industry())
	var installation = g_Scene.get_area(id).installation
	if installation > 0:
		$Installation.texture = res.get_image(_INSTALLATION_STAMP[installation - 1])
	else:
		$Installation.texture = null
	if g_Scene.get_area(id).has_army_card(3):
		$WithCommander.visible = true
		$WithoutCommander.visible = false
		var country = g_Scene.get_area(id).country
		if country.ai:
			var commander = country.get_commander_name()
			if not commander.is_empty():
				var photo := CObjectDef.instance().get_general_photo(commander)
				var photo_name := "general_common.png"
				if photo != null:
					photo_name = photo.filename
					photo_name = photo_name.substr(0, photo_name.rfind(".")) + ".png"
				$WithCommander/Commander.texture = res.get_image(photo_name)
				$WithCommander/CommanderMedal.queue_redraw()
		else:
			$WithCommander/Commander.texture = res.get_image("general_player.png")
			$WithCommander/CommanderMedal.queue_redraw()
	else:
		$WithCommander.visible = false
		$WithoutCommander.visible = true


func set_money(value: int) -> void:
	if value != money:
		money = value
		$Money.text = "{0}".format([value])


func set_industry(value: int) -> void:
	if value != industry:
		industry = value
		$Industry.text = "{0}".format([value])


func _on_commander_medal_draw() -> void:
	var country = g_Scene.get_area(area).country
	if country.ai:
		g_GameRes.render_ai_commander_medal($WithCommander/CommanderMedal.get_canvas_item(), 1, 0.0, 0.0, country.name, country.alliance)
	else:
		g_GameRes.render_commander_medal($WithCommander/CommanderMedal.get_canvas_item(), 1, 0.0, 0.0, country.get_commander_level())
