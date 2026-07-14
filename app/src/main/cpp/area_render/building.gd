extends Node2D

@export
var installation_position: Vector2i:
	set(value):
		if value != installation_position:
			installation_position = value
			if _installation != null:
				_installation.postion = value as Vector2 - position


@export
var construction_type: int:
	set(value):
		if value != construction_type:
			construction_type = value
			if _construction != null:
				_construction.type = value


@export
var construction_level: int:
	set(value):
		if value != construction_level:
			construction_level = value
			if _construction != null:
				_construction.level = value


@export
var installation_type: int:
	set(value):
		if value != installation_type:
			installation_type = value
			if _installation != null:
				_installation.type = value


@export
var area_type: int:
	set(value):
		if value != area_type:
			area_type = value
			if value == 2:
				if _port == null:
					_port = $Port.create_instance()
				if _construction != null:
					_construction.queue_free()
					_construction = null
				if _installation != null:
					_installation.queue_free()
					_installation = null
			else:
				if _port != null:
					_port.queue_free()
					_port = null
				if _construction == null:
					_construction = $Construction.create_instance()
					_construction.type = construction_type
					_construction.level = construction_level
				if _installation == null:
					_installation = $Installation.create_insatance()
					_installation.postion = installation_position as Vector2 - position
					_installation.type = installation_type


var _port: Node2D
var _construction: Node2D
var _installation: Node2D
