extends GUIElement

## In the original game code, this element is as big as the board, and its
## parent is resposible of putting it in the center. In this Godot port, this
## element should occupy the whole screen (for the fading out of elements below)
## and put the board in the center by itself.

const _BATTLE_INTRO_KEY_FORMAT = [
	"axis battle intro {0}",
	"allies battle intro {0}",
	"wto battle intro {0}",
	"nato battle intro {0}"
]
const _BATTLE_NAME_KEY_FORMAT = [
	"axis battle name {0}",
	"allies battle name {0}",
	"wto battle name {0}",
	"nato battle name {0}"
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

func init() -> void:
	if not is_node_ready():
		return
	super()
	var battle_intro = $Font4/BattleIntro/Label
	if ecGraphics.instance().content_scale_size_mode == 3:
		battle_intro.add_theme_constant_override("line_spacing", -6)
	else:
		battle_intro.add_theme_constant_override("line_spacing", -3)
	_set_battle()


func _set_battle() -> void:
	var string_table := g_StringTable
	if campaign >= 0 and campaign < 4:
		$Font4/BattleIntro/Label.text = _BATTLE_INTRO_KEY_FORMAT[campaign].format([battle + 1])
		$BattleName/ecText.text = _BATTLE_NAME_KEY_FORMAT[campaign].format([battle + 1])
	var battle_key_name = AppDelegate.get_battle_key_name(campaign, battle)
	var battle_def := CObjectDef.instance().get_battle_def(battle_key_name)
	$Font4/Age/Num7/Label.text = battle_def.age
	var v1 = string_table.get_string("victory days1")
	var v2 = string_table.get_string("victory days2")
	var v := $Font4/VictoryDays/Label
	var gv := $Font4/GreatVictoryDays/Label
	if not v1.is_empty():
		v.text = "%s %d %s"%[v1, battle_def.victory, v2]
		gv.text = "%s %d %s"%[v1, battle_def.greatvictory, v2]
	else:
		v.text = "%d%s"%[battle_def.victory, v2]
		gv.text = "%d%s"%[battle_def.greatvictory, v2]


func _on_gui_button_ex_pressed() -> void:
	ok_pressed.emit()


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
	elif event.is_action_released(&"ui_cancel"):
		ok_pressed.emit()
		accept_event()
