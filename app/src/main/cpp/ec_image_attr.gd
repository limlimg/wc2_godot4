
const _ecTexture = preload("res://app/src/main/cpp/ec_texture.gd")

var texture: _ecTexture
var region: Rect2
var ref: Vector2

var x: float:
	get():
		return region.position.x
	set(value):
		region.position.x = value


var y: float:
	get():
		return region.position.y
	set(value):
		region.position.y = value


var w: float:
	get():
		return region.size.x
	set(value):
		region.size.x = value


var h: float:
	get():
		return region.size.y
	set(value):
		region.size.y = value


var refx: float:
	get():
		return ref.x
	set(value):
		ref.x = value


var refy: float:
	get():
		return ref.y
	set(value):
		ref.y = value
