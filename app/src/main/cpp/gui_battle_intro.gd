extends "res://app/src/main/cpp/gui_element.gd"

## In the original game code, this element is as big as the board, and its
## parent is resposible of putting it in the center. In this Godot port, this
## element should occupy the whole screen (for the fading out of elements below)
## and put the board in the center by itself.

const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _CObjectDef = preload("res://app/src/main/cpp/c_object_def.gd")


const _BATTLE_INTRO_KEY_FORMAT = [
	"axis battle intro %d",
	"allies battle intro %d",
	"wto battle intro %d",
	"nato battle intro %d"
]
const _BATTLE_NAME_KEY_FORMAT = [
	"axis battle name %d",
	"allies battle name %d",
	"wto battle name %d",
	"nato battle name %d"
]

@export
var campaign: int:
	set(value):
		if value != campaign:
			campaign = value
			_set_battle()


@export
var battle: int:
	set(value):
		if value != battle:
			battle = value
			_set_battle()


signal ok_pressed

func _ready() -> void:
	init()


func init() -> void:
	var battle_intro = $CenterContainer/BoardIntro/TextureRect/BattleIntro/ecText
	if _ecGraphics.instance().content_scale_size_mode == 3:
		battle_intro.add_theme_constant_override("line_spacing", -6)
	else:
		battle_intro.add_theme_constant_override("line_spacing", -3)
	$CenterContainer/BoardIntro/TextureRect/Victory/ecText.text = _native.g_string_table.get_string("victory")
	$CenterContainer/BoardIntro/TextureRect/GreatVictory/ecText.text = _native.g_string_table.get_string("great victory")
	_set_battle()


func _set_battle() -> void:
	var string_table := _native.g_string_table
	if campaign >= 0 and campaign < 4:
		$CenterContainer/BoardIntro/TextureRect/BattleIntro/ecText.text = string_table.get_string(_BATTLE_INTRO_KEY_FORMAT[campaign]%[battle + 1])
		$CenterContainer/BoardIntro/TextureRect/BattleName/ecText.text = string_table.get_string(_BATTLE_NAME_KEY_FORMAT[campaign]%[battle + 1])
	var battle_key_name := _native.get_battle_key_name(campaign, battle)
	var battle_def := _CObjectDef.instance().get_battle_def(battle_key_name)
	$CenterContainer/BoardIntro/TextureRect/Age/ecText.text = battle_def.age
	var v1 := string_table.get_string("victory days1")
	var v2 := string_table.get_string("victory days2")
	var v := $CenterContainer/BoardIntro/TextureRect/VictoryDays/ecText
	var gv := $CenterContainer/BoardIntro/TextureRect/GreatVictoryDays/ecText
	if not v1.is_empty():
		v.text = "%s %d %s"%[v1, battle_def.victory, v2]
		gv.text = "%s %d %s"%[v1, battle_def.greatvictory, v2]
	else:
		v.text = "%d%s"%[battle_def.victory, v2]
		gv.text = "%d%s"%[battle_def.greatvictory, v2]


func _on_gui_button_ex_pressed() -> void:
	ok_pressed.emit()
