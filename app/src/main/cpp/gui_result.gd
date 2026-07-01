extends "res://app/src/main/cpp/gui_element.gd"

signal next_pressed
signal restart_pressed

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

func _ready() -> void:
	init()


func init() -> void:
	var num_stars := g_GameManager.get_num_victory_stars()
	while _stars.size() < num_stars:
		var star := $RankStar/Prototype/RankStar.duplicate()
		$RankStar/HBoxContainer.add_child(star)
		_stars.append(star)
	while _stars.size() > num_stars:
		_stars.pop_back().queue_free()
	if num_stars == 5:
		$Rank/Rank.show()
		$Rank/Rank2.hide()
	$Round/Label.text = "{0}".format([g_GameManager.current_round + 1])
	$RandomRewardMedal/Label.text = "{0}".format([g_GameManager.random_reward_medal])
	$CampaignRewardMedal/Label.text = "{0}".format([g_GameManager.campaign_reward_medal])


func _on_gui_button_back_pressed() -> void:
	back_pressed.emit()


func _on_gui_button_next_pressed() -> void:
	next_pressed.emit()


func _on_gui_button_restart_pressed() -> void:
	restart_pressed.emit()
