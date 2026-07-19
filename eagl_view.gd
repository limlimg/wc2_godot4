extends Control

func _ready() -> void:
	CStateManager.instance().show()
	GUIManager.instance().show()
