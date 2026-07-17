extends Node2D

@export
var country: String:
	set(value):
		if value != country:
			country = value
			queue_redraw()


@export
var id: int:
	set(value):
		if value != id:
			id = value
			queue_redraw()


@export
var carrier: bool:
	set(value):
		if value != carrier:
			carrier = value
			queue_redraw()


@export
var durability: int:
	set(value):
		if value != durability:
			durability = value
			queue_redraw()


@export
var max_durability: int:
	set(value):
		if value != max_durability:
			max_durability = value
			queue_redraw()


@export
var movement: int:
	set(value):
		if value != movement:
			movement = value
			queue_redraw()


@export
var cards: int:
	set(value):
		if value != cards:
			cards = value
			queue_redraw()


@export
var level: int:
	set(value):
		if value != level:
			level = value
			queue_redraw()


func _draw() -> void:
	ecGraphics.instance().render_begin(self)
	g_GameRes.render_ui_army(country, 0.0, 0.0, id, false, durability, max_durability, movement, cards, level)
	ecGraphics.instance().render_end()
	
