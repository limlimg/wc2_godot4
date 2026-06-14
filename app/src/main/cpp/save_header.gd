class_name SaveHeader
extends Resource

const _SaveCountryInfo = preload("res://app/src/main/cpp/save_country_info.gd")
const _SaveAreaInfo = preload("res://app/src/main/cpp/save_area_info.gd")
const _DialogueDef = preload("res://app/src/main/cpp/dialogue_def.gd")

var game_mode: int

@export
var map: int

@export
var areas_enable: String

var player_country_name: Array[String]
var battle_file_name: String
var camera_x: float
var camera_y: float
var camera_scale: float
var current_country_index: int
var current_dialogue_index: int
var country_count: int
var area_count: int
var current_round: int
var random_reward_medal: int
var save_time_year: int
var save_time_month: int
var save_time_day: int
var save_time_hour: int
var save_time_min: int
var campaign: int
var battle: int
var victory: int
var great_victory: int

@export
var country: Array[_SaveCountryInfo]

@export
var area: Array[_SaveAreaInfo]

@export
var dialogue: Array[_DialogueDef]
