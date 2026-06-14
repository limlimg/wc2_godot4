class_name SaveAreaInfo
extends Resource

const _SaveArmyInfo = preload("uid://b2atnix13pfgu")

@export
var id: int

@export
var construction: int

@export
var level: int

@export
var installation: int

@export
var country: StringName

@export
var army: Array[_SaveArmyInfo]
