extends GUIElement

signal next_pressed
signal restart_pressed
signal back_pressed

@export
var show_restart: bool:
	set(value):
		show_restart = value
		if value:
			$ButtonNext.visible = false
			$ButtonRestart.visible = g_GameManager.game_mode != 4
		else:
			$ButtonRestart.visible = false
			$ButtonNext.visible = g_GameManager.game_mode == 1


var _stars: Array[Control]

func init() -> void:
	if not is_node_ready():
		return
	super()
	var num_stars = g_GameManager.get_num_victory_stars()
	while _stars.size() < num_stars:
		var star := $RankStar/Prototype/RankStar.duplicate()
		$RankStar/HBoxContainer.add_child(star)
		_stars.append(star)
	while _stars.size() > num_stars:
		_stars.pop_back().queue_free()
	if num_stars == 5:
		$Rank/Rank.show()
		$Rank/Rank2.hide()
	$Round/ecText.text = "{0}".format([g_GameManager.current_round + 1])
	$RandomRewardMedal/ecText.text = "{0}".format([g_GameManager.random_reward_medal])
	$CampaignRewardMedal/ecText.text = "{0}".format([g_GameManager.campaign_reward_medal])


func _on_gui_button_back_pressed() -> void:
	back_pressed.emit()


func _on_gui_button_next_pressed() -> void:
	next_pressed.emit()


func _on_gui_button_restart_pressed() -> void:
	restart_pressed.emit()


func _has_point(_point: Vector2) -> bool:
	return is_visible_in_tree()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
	elif event.is_action_released(&"ui_cancel"):
		back_pressed.emit()
		accept_event()
