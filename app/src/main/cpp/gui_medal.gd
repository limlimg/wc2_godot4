extends Control

## GUIMedal shows the number of medals the player has. The button for in-game
## purchasing is not added.
## 
## This class is a good example of observer patten recommended by Godot.
## Autoload g_Commander, which stores the number, emit a signal to notify
## changes, instead of GUIMedal reading the number every frame.

var _medal := -1:
	set = set_medal

func init() -> void:
	set_medal(g_Commander.medal)


func set_medal(value: int) -> void:
	if value != _medal:
		_medal = value
		$GUIRect/Control/Label.text = str(value)


func _ready() -> void:
	init()
	g_Commander.medal_changed.connect(set_medal)
