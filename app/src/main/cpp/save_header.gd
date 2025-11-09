
var game_mode: int
var map_id: int
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
var current_turn_num_minus_1: int
var random_reward_medal: int
var save_time_year: int
var save_time_month: int
var save_time_day: int
var save_time_hour: int
var save_time_min: int
var campaign: int
var battle: int
var victory_turn: int
var great_victory_turn: int

func _init() -> void:
	player_country_name.resize(4)
