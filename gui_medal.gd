extends GUIElement

## GUIMedal shows the number of medals the player has. The button for in-game
## purchasing is not added.
## 
## This class is a good example of observer patten recommended by Godot.
## Autoload _lib.g_Commander, which stores the number, emit a signal to notify
## changes, instead of GUIMedal reading the number every frame.

@export
var _medal := 0:
	set = set_medal


func set_medal(value: int) -> void:
	if value != _medal:
		_medal = value
		$GUIElement/ecText.set_text(str(value))


func _process(_delta: float) -> void:
	set_medal(g_Commander.medal)
