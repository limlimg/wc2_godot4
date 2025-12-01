class_name BattleDef
extends Resource

const _FlagInfo = preload("res://app/src/main/cpp/flag_info.gd")

@export_storage
var name: StringName

@export
var centerx: float

@export
var centery: float

@export
var age: String

@export
var agex: float

@export
var agey: float

@export
var victory: int

@export
var greatvictory: int

@export
var flag: Array[_FlagInfo]

@export
var arrow: Array[_FlagInfo]
