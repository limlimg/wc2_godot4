extends Control

## In the original game code, GUIElements are, as its name suggests, components
## of the graphical user interface. They are organized in a tree structure, with
## GUIManager::Instance() always being the root. They communicate with each
## other via OnEvent method. Inputs trigger this method and spread to the
## children of an element if not handled by its OnEvent method. Elements can
## also create events which spread along its ancestors. This kind of events
## usually reach the GUIManager which then send them to the current active state.
## OnUpdate method updates the element and OnRender renders the element.
##
## In this projects, GUIElements inherits Control node class. Inputs should be
## received via engine callbacks. Create events as signals that the actual
## receiver connects. Updating should be handled by _process. Rendering should
## be handled by children nodes. Many other methods are also provided by the
## base classes.
## 
## The original SetVisible method is unused and not implemented due to name
## conflict with engine method. FindByHandle is unused and not implemented.

const _ecGraphics = preload("res://app/src/main/cpp/ec_graphics.gd")

func free_child(child: Node) -> void:
	remove_child(child)
	if child != null:
		child.free()


func free_all_child() -> void:
	var child := get_child(0)
	while child != null:
		free_child(child)
		child = get_child(0)


func get_pos() -> Vector2:
	return position


func set_pos(x: float, y: float) -> void:
	position = Vector2(x, y)


func move(x: float, y: float) -> void:
	position += Vector2(x, y)


func center() -> void:
	var c: Vector2
	var parent := get_parent_control()
	if parent != null:
		c = parent.size / 2
	else:
		var graphics := _ecGraphics.instance()
		c = Vector2(graphics.orientated_content_scale_width, graphics.orientated_content_scale_height)
	position = c - size / 2


func get_abs_rect() -> Rect2:
	return get_global_rect()


func check_in_rect(x: float, y: float, rect := get_abs_rect()) -> bool:
	return rect.has_point(Vector2(x, y))


func set_enable(value: bool) -> void:
	if "enable" in self:
		self.enable = value
