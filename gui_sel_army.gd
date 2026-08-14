extends GUIElement

@export
var area: int:
	set = set_area

var targeting: bool

signal army_targeted(index: int)

func set_area(value: int) -> void:
	if value != area:
		area = value
		var c_area = g_Scene.get_area(value)
		var army_count = c_area.get_num_armies()
		for i in $VBoxContainer.get_child_count():
			var node := $VBoxContainer.get_child(i)
			if i < army_count:
				node.army = c_area.get_army(i)
			else:
				node.army = null


func _on_gui_army_item_pressed(index: int) -> void:
	if targeting:
		target_army(index)
	else:
		move_army_to_front(index)


func target_army(index: int) -> void:
	army_targeted.emit(index)


func move_army_to_front(index: int) -> void:
	var moving_army = $VBoxContainer.get_child(index).army
	if moving_army == null:
		return
	if index >= 3:
		$VBoxContainer/GUIArmyItem4.army = $VBoxContainer/GUIArmyItem3.army
	if index >= 2:
		$VBoxContainer/GUIArmyItem3.army = $VBoxContainer/GUIArmyItem2.army
	if index >= 1:
		$VBoxContainer/GUIArmyItem2.army = $VBoxContainer/GUIArmyItem.army
	$VBoxContainer/GUIArmyItem.army = moving_army
	g_Scene.get_area(area).move_army_to_front(index, true)
	if g_GameManager.game_mode == 4:
		# TODO: send multiplayer data
		pass


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
