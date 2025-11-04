extends Node

const _MAGIC = "EASY"
const _DOCUMENT_SIZE = 0x17C
const _UPGRADE_MEDAL = [5, 8, 12, 19, 30, 48, 75, 120, 190, 300, 480, 760, 1200, 2000]
const _ecFile = preload("res://app/src/main/cpp/ec_file.gd")
const _native = preload("res://app/src/main/cpp/native-lib.gd")
const _CSoundBox = preload("res://app/src/main/cpp/c_sound_box.gd")
const _WARMEDAL_ID = preload("res://app/src/main/cpp/war_medal_id.gd").WARMEDAL_ID
const _CommanderData = preload("res://app/src/main/cpp/commander_data.gd")

var _loaded := false
var rank: int
var medal := 50
var bought_medal := 0
var war_medal: Array[int] = [0, 0, 0, 0, 0, 0]
var num_played_battles: Array[int] = [0, 0, 0, 0]
var num_battle_stars: Array[PackedInt32Array] = []

func _init() -> void:
	num_battle_stars.resize(4)
	for a in num_battle_stars:
		a.resize(20)
		a.fill(0)


func _enter_tree() -> void:
	self.load()


func load() -> void:
	_loaded = true
	var file := _ecFile.new()
	if file.open(_native.get_document_path("commander.sav"), FileAccess.READ):
		var buffer := PackedByteArray()
		if file.read(buffer, _DOCUMENT_SIZE) and buffer.slice(0, 4).get_string_from_ascii().reverse() == _MAGIC and buffer.decode_u32(4) == 1:
			rank = buffer.decode_u32(16)
			medal = buffer.decode_u32(12)
			bought_medal = buffer.decode_u32(8)
			war_medal[0] = buffer.decode_u32(20)
			war_medal[1] = buffer.decode_u32(24)
			war_medal[2] = buffer.decode_u32(28)
			war_medal[3] = buffer.decode_u32(32)
			war_medal[4] = buffer.decode_u32(36)
			war_medal[5] = buffer.decode_u32(40)
			num_played_battles[0] = buffer.decode_u32(44)
			num_played_battles[1] = buffer.decode_u32(48)
			num_played_battles[2] = buffer.decode_u32(52)
			num_played_battles[3] = buffer.decode_u32(56)
			var offset := 60
			for a in num_battle_stars:
				for i in a.size():
					a[i] = buffer.decode_u32(offset)
					offset += 4


func _exit_tree() -> void:
	save()


func save() -> void:
	if _loaded:
		var buffer: PackedByteArray
		buffer.append_array(_MAGIC.reverse().to_ascii_buffer())
		buffer.resize(_DOCUMENT_SIZE)
		buffer.encode_u32(4, 1)
		buffer.encode_u32(8, bought_medal)
		buffer.encode_u32(12, medal)
		buffer.encode_u32(16, rank)
		buffer.encode_u32(20, war_medal[0])
		buffer.encode_u32(24, war_medal[1])
		buffer.encode_u32(28, war_medal[2])
		buffer.encode_u32(32, war_medal[3])
		buffer.encode_u32(36, war_medal[4])
		buffer.encode_u32(40, war_medal[5])
		buffer.encode_u32(44, num_played_battles[0])
		buffer.encode_u32(48, num_played_battles[1])
		buffer.encode_u32(52, num_played_battles[2])
		buffer.encode_u32(56, num_played_battles[3])
		var offset := 60
		for a in num_battle_stars:
			for x in a:
				buffer.encode_u32(offset, x)
				offset += 4
		var file := _ecFile.new()
		if file.open(_native.get_document_path("commander.sav"), FileAccess.WRITE):
			file.write(buffer, _DOCUMENT_SIZE)
			file.close()


func get_upgrade_medal() -> int:
	if is_max_level():
		return 0
	else:
		return _UPGRADE_MEDAL[rank]


func check_upgrade() -> bool:
	return not is_max_level() and medal >= get_upgrade_medal()


func upgrade() -> void:
	if check_upgrade():
		medal -= get_upgrade_medal()
		rank += 1


func is_max_level() -> bool:
	return rank > 13


func buy_medal(value: int) -> void:
	bought_medal += value
	medal += value
	_CSoundBox.get_instance().play_se("buy.wav")


func get_war_medal_level(id: _WARMEDAL_ID) -> int:
	return war_medal[id]


func get_need_upgrade_medal(id: _WARMEDAL_ID) -> int:
	var level = get_war_medal_level(id)
	if level > 2:
		return 0
	else:
		return 100 * (level + 2)


func check_upgrade_war_medal(id: _WARMEDAL_ID) -> bool:
	return get_war_medal_level(id) <= 2 and medal >= get_need_upgrade_medal(id)


func upgrade_war_medal(id: _WARMEDAL_ID) -> void:
	if check_upgrade_war_medal(id):
		medal -= get_need_upgrade_medal(id)
		war_medal[id] += 1


func get_num_played_battles(campaign: int) -> int:
	return num_played_battles[campaign]


func set_num_played_battles(campaign: int, value: int) -> void:
	num_played_battles[campaign] = value


func set_battle_played(campaign: int, battle: int) -> void:
	if get_num_played_battles(campaign) <= battle:
		set_num_played_battles(campaign, battle + 1)


func get_num_battle_stars(campaign: int, battle: int) -> int:
	return num_battle_stars[campaign][battle]


func set_num_battle_stars(campaign: int, battle: int, value: int) -> void:
	num_battle_stars[campaign][battle] = value


func get_commander_data(data: _CommanderData) -> void:
	data.rank = rank
	data.infantry = war_medal[0]
	data.airforce = war_medal[1]
	data.artillery = war_medal[2]
	data.armour = war_medal[3]
	data.navy = war_medal[4]
	data.honour = war_medal[5]
