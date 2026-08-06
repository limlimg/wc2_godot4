extends GUIElement

const _INSTALLATION_STAMP = [
	"stamp_fortress.png",
	"stamp_wire.png",
	"stamp_aagun.png",
	"stamp_radar.png"
]

@export
var money := 0:
	set = set_money

@export
var industry := 0:
	set = set_industry

func set_area(id: int) -> void:
	var area = g_Scene.get_area(id)
	set_money(area.get_real_tax())
	set_industry(area.get_industry())
	var installation = area.installation
	if installation > 0:
		$Installation.texture = texture_res.get_res().get_image(_INSTALLATION_STAMP[installation])
	else:
		$Installation.texture = null
	if area.has_army_card(3):
		$WithCommander.visible = true
		$WithoutCommander.visible = false
		var country = area.country
		if country.ai:
			$WithCommander/IsAI.visible = true
			$WithCommander/NotAI.visible = false
			var commander = country.get_commander_name()
			if not commander.is_empty():
				var photo := CObjectDef.instance().get_general_photo(commander)
				var photo_name := "general_common.png"
				if photo != null:
					photo_name = photo.filename
					photo_name = photo_name.substr(0, photo_name.rfind(".")) + ".png"
				$WithCommander/Commander.texture = texture_res.get_image(photo_name)
				$WithCommander/IsAI/AICommanderMedal.country = country.name
				$WithCommander/IsAI/AICommanderMedal.common = country.alliance
		else:
			$WithCommander/IsAI.visible = false
			$WithCommander/NotAI.visible = true
			$WithCommander/Commander.texture = texture_res.get_image("general_player.png")
			$WithCommander/NotAI/CommanderMedal.commander_level = country.get_commander_level()
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
