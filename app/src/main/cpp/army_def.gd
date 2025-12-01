class_name ArmyDef
extends Resource

const ARMY_TYPE = [
	"infantry",
	"panzer",
	"artillery",
	"rocket",
	"tank",
	"heavytank",
	"destroyer",
	"cruiser",
	"battleship",
	"aircraftcarrier",
	"carrier",
	"airstrike",
	"bomber",
	"airborne",
	"nuclearbomb"
]

@export_storage
var id: int

@export
var strength: int

@export
var movement: int

@export
var minatk: int

@export
var maxatk: int
