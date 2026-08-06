extends Control

func _ready() -> void:
	Engine.max_fps = 60
	CStateManager.instance().show()
