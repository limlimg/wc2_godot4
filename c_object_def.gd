class_name CObjectDef
extends Object

static var _m_instance: CObjectDef

var _army_def: ArmyDefListMap
var _card_def: CardDefList
var _unit_motions: UnitMotionsMap
var _unit_positions: UnitPositionsMap
var _commander_def: CommanderDefMap
var _general_photos: GeneralPhotoMap
var _battle_list: BattleDefMap
var _conquest_list: ConquestDefMap

static func instance() -> CObjectDef:
	if _m_instance == null:
		_m_instance = new()
	return _m_instance


static func destroy() -> void:
	if _m_instance != null:
		_m_instance._release()
		_m_instance.free()
	_m_instance = null


func init() -> void:
	_load_army_def()
	_load_card_def()
	_load_unit_motions()
	_load_unit_positions()
	_load_commander_def()
	_load_general_photos()
	_load_battle_list()
	_load_conquest_list()


func _release() -> void:
	_release_army_def()
	_release_unit_motions()
	_release_unit_positions()
	_release_commander_def()
	_release_general_photos()
	_release_battle_list()
	_release_conquest_list()

func _load_army_def() -> void:
	_army_def = load(EC2dAppDelegate.get_asset_path("armydef.xml", "")) as ArmyDefListMap
	if _army_def == null:
		push_error("Failed to load armydef.xml")


func _release_army_def() -> void:
	_army_def = null


func get_army_def(id: int, country: StringName) -> ArmyDef:
	if country in _army_def.countries:
		return _army_def.countries[country].armies[id]
	else:
		return _army_def.others.armies[id]


func _load_card_def() -> void:
	_card_def = load(EC2dAppDelegate.get_asset_path("carddef.xml", "")) as CardDefList
	if _card_def == null:
		push_error("Failed to load carddef.xml")


func get_card_def(id: int) -> CardDef:
	return _card_def.cards[id]


func get_card_target_type(card: CardDef) -> int:
	var id := card.id
	if id == 21:
		return 0
	elif id < 22 or id >= 26:
		return 1
	else:
		return 5


func _load_unit_motions() -> void:
	_unit_motions = load(EC2dAppDelegate.get_asset_path("motiondef.xml", "")) as UnitMotionsMap
	if _unit_motions == null:
		push_error("Failed to load motiondef.xml")


func _release_unit_motions() -> void:
	_unit_motions = null


func get_unit_motions(type: String, country: String) -> UnitMotions:
	if country != "":
		var key := "{0} {1}".format([type, country])
		if _unit_motions.units.has(key):
			return _unit_motions.units[key]
	return _unit_motions.units.get(type)


func _load_unit_positions() -> void:
	_unit_positions = load(EC2dAppDelegate.get_asset_path("unitposdef.xml", "")) as UnitPositionsMap
	if _unit_positions == null:
		push_error("Failed to load unitposdef.xml")


func _release_unit_positions() -> void:
	_unit_positions = null


func get_unit_positions(type: StringName) -> UnitPositions:
	return _unit_positions.units.get(type)


func _load_commander_def() -> void:
	_commander_def = load(EC2dAppDelegate.get_asset_path("commanderdef.xml", "")) as CommanderDefMap
	if _commander_def == null:
		push_error("Failed to load commanderdef.xml")


func _release_commander_def() -> void:
	_commander_def = null


func get_commander_def(def_name: StringName) -> CommanderDef:
	return _commander_def.commanders.get(def_name)


func _load_general_photos() -> void:
	_general_photos = load(EC2dAppDelegate.get_asset_path("generalphotos.xml", "")) as GeneralPhotoMap
	if _general_photos == null:
		push_error("Failed to load generalphotos.xml")


func _release_general_photos() -> void:
	_general_photos = null


func get_general_photo(def_name: StringName) -> GeneralPhoto:
	return _general_photos.generals[def_name]


func _load_battle_list() -> void:
	_battle_list = load(EC2dAppDelegate.get_asset_path("battlelist.xml", "")) as BattleDefMap
	if _battle_list == null:
		push_error("Failed to load battlelist.xml")


func _release_battle_list() -> void:
	_battle_list = null


func get_battle_def(def_name: StringName) -> BattleDef:
	return _battle_list.battlelist.get(def_name)


func _load_conquest_list() -> void:
	_conquest_list = load(EC2dAppDelegate.get_asset_path("conquestlist.xml", "")) as ConquestDefMap
	if _conquest_list == null:
		push_error("Failed to load conquestlist.xml")


func _release_conquest_list() -> void:
	_conquest_list = null


func get_conquest_def(def_name: StringName) -> ConquestDef:
	return _conquest_list.battlelist.get(def_name)
