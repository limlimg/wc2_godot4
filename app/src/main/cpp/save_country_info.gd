class_name SaveCountryInfo
extends Resource

@export
var money: int

@export
var industry: int

@export
var techlevel: int

var tech_developing_round: int

@export
var ai: bool

@export
var alliance: int

@export
var defeated: int

var cards_round: PackedInt32Array

@export
var id: StringName

@export
var name: StringName

@export
var color: Color

@export
var tax_factor: float

var enemies_destroyed: PackedInt32Array
var war_medal: PackedInt32Array

@export
var commander: StringName

var commander_round: int
var commander_alive: bool
var borrowed_loan: bool
var is_defeated: bool
