extends "res://app/src/main/cpp/native-lib.gd"

const _ArmyDef = preload("res://app/src/main/cpp/imported/army_def.gd")
const _ArmyDefListMap = preload("res://app/src/main/cpp/imported/army_def_list_map.gd")
const _CardDef = preload("res://app/src/main/cpp/imported/card_def.gd")
const _CardDefList = preload("res://app/src/main/cpp/imported/card_def_list.gd")
const _UnitMotions = preload("res://app/src/main/cpp/imported/unit_motions.gd")
const _UnitMotionsMap = preload("res://app/src/main/cpp/imported/unit_motions_map.gd")
const _UnitPositions = preload("res://app/src/main/cpp/imported/unit_positions.gd")
const _UnitPositionsMap = preload("res://app/src/main/cpp/imported/unit_positions_map.gd")
const _CommanderDef = preload("res://app/src/main/cpp/imported/commander_def.gd")
const _CommanderDefMap = preload("res://app/src/main/cpp/imported/commander_def_map.gd")
const _GeneralPhoto = preload("res://app/src/main/cpp/imported/general_photo.gd")
const _GeneralPhotoMap = preload("res://app/src/main/cpp/imported/general_photo_map.gd")

var _army_def: _ArmyDefListMap
var _card_def: _CardDefList
var _unit_motions: _UnitMotionsMap
var _unit_positions: _UnitPositionsMap
var _commander_def: _CommanderDefMap
var _general_photos: _GeneralPhotoMap

func _load_army_def() -> void:
	_army_def = load(get_path("armydef.xml", "")) as _ArmyDefListMap
	if _army_def == null:
		push_error("Failed to load armydef.xml")


func _release_army_def() -> void:
	_army_def = null


func get_army_def(id: int, country: StringName) -> _ArmyDef:
	if country in _army_def.countries:
		return _army_def.countries[country].armies[id]
	else:
		return _army_def.others.armies[id]


func _load_card_def() -> void:
	_card_def = load(get_path("carddef.xml", "")) as _CardDefList
	if _card_def == null:
		push_error("Failed to load carddef.xml")


func get_card_def(id: int) -> _CardDef:
	return _card_def.cards[id]


func get_card_target_type(card: _CardDef) -> int:
	var id := card.id
	if id == 21:
		return 0
	elif id < 22 or id >= 26:
		return 1
	else:
		return 5


func _load_unit_motions() -> void:
	_unit_motions = load(get_path("motiondef.xml", "")) as _UnitMotionsMap
	if _unit_motions == null:
		push_error("Failed to load motiondef.xml")


func _release_unit_motions() -> void:
	_unit_motions = null


func get_unit_motions(type: String, country: String) -> _UnitMotions:
	if country != "":
		var key := "{0} {1}".format([type, country])
		if _unit_motions.units.has(key):
			return _unit_motions.units[key]
	return _unit_motions.units.get(type)


func _load_unit_positions() -> void:
	_unit_positions = load(get_path("unitposdef.xml", "")) as _UnitPositionsMap
	if _unit_positions == null:
		push_error("Failed to load unitposdef.xml")


func _release_unit_positions() -> void:
	_unit_positions = null


func get_unit_positions(type: StringName) -> _UnitPositions:
	return _unit_positions.units.get(type)


func _load_commander_def() -> void:
	_commander_def = load(get_path("commanderdef.xml", "")) as _CommanderDefMap
	if _commander_def == null:
		push_error("Failed to load commanderdef.xml")


func _release_commander_def() -> void:
	_commander_def = null


func get_commander_def(name: StringName) -> _CommanderDef:
	return _commander_def.commanders.get(name)


func _load_general_photos() -> void:
	_general_photos = load(get_path("generalphotos.xml", "")) as _GeneralPhotoMap
	if _general_photos == null:
		push_error("Failed to load generalphotos.xml")


func _release_general_photos() -> void:
	_general_photos = null


func get_general_photo(name: StringName) -> _GeneralPhoto:
	return _general_photos.generals[name]
