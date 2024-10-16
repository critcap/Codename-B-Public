extends Node

const STATS_DIR = "res://data/stats"
const ITEMS_DIR = "res://data/items"
const MAP_DIR = "res://data/maps"
const ENEMY_DIR = "res://data/enemies"
const WEAPONS_DIR = "res://data/weapons"
const CHARACTERS_DIR = "res://data/characters"

@export var stat_info: Array[StatData]
@export var item_data: Array[ItemData]
@export var map_data: Array[MapData]
@export var enemy_data: Array[EnemyData]
@export var weapon_data: Array[WeaponData]
@export var character_data: Array[PlayerCharacterData]

## force the database to be rebuilt on start
var force: bool = false
var _db: DataDb

func _ready() -> void:
	var is_web: bool = false
	for platform in [&"web_android", &"web_ios", &"web_linuxbsd", &"web_macos", &"web_windows"]:
		if OS.has_feature(platform):
			is_web = true
			break

	# build the database when in debug mode
	if OS.is_debug_build() and !is_web and !force:
		stat_info = _load_stat_data(STATS_DIR)
		item_data = _load_item_data(ITEMS_DIR)
		map_data = _load_map_data(MAP_DIR)
		enemy_data = _load_enemy_data(ENEMY_DIR)
		character_data = _load_character_data(CHARACTERS_DIR)
		weapon_data = _load_weapon_data(WEAPONS_DIR)
		var db := DataDb.new()
		db.characters = character_data
		db.weapons = weapon_data
		db.enemies = enemy_data
		db.maps = map_data
		db.items = item_data
		db.stats = stat_info
		var dir := DirAccess.open("res://data/")
		if dir.file_exists("res://data/Data.tres"):
			dir.remove("res://data/Data.tres")
		ResourceSaver.save(db, "res://data/Data.tres")
		return

	#only load when not in debug mode and not in web
	_db = load("res://data/Data.tres") as DataDb
	assert(_db != null, "Failed to load database")
	assert(_db.stats.is_empty() == false, "Failed to load stats")
	assert(_db.items.is_empty() == false, "Failed to load items")
	assert(_db.maps.is_empty() == false, "Failed to load maps")
	assert(_db.enemies.is_empty() == false, "Failed to load enemies")
	assert(_db.characters.is_empty() == false, "Failed to load characters")
	assert(_db.weapons.is_empty() == false, "Failed to load weapons")

	stat_info = _db.stats
	item_data = _db.items
	map_data = _db.maps
	enemy_data = _db.enemies
	character_data = _db.characters
	weapon_data = _db.weapons


func build_db() -> int:
	stat_info = _load_stat_data(STATS_DIR)
	item_data = _load_item_data(ITEMS_DIR)
	map_data = _load_map_data(MAP_DIR)
	enemy_data = _load_enemy_data(ENEMY_DIR)
	character_data = _load_character_data(CHARACTERS_DIR)
	weapon_data = _load_weapon_data(WEAPONS_DIR)

	var db := DataDb.new()
	db.characters = character_data
	db.weapons = weapon_data
	db.enemies = enemy_data
	db.maps = map_data
	db.items = item_data
	db.stats = stat_info
	var dir := DirAccess.open("res://data/")
	if dir.file_exists("res://data/Data.tres"):
		dir.remove("res://data/Data.tres")
	return ResourceSaver.save(db, "res://data/Data.tres")


func _load_map_data(dir: String) -> Array[MapData]:
	var files := _open_dir(dir)
	if files.is_empty():
		return []
	var maps: Array[MapData] = []

	for file in files:
		var path := dir + "/" + file
		var map: MapData = load(path)
		if maps.size() >= map.id && maps[map.id] != null:
			printerr("Map ID conflict: " + str(map.id))
			continue
		maps.append(map)
	return maps


func _load_weapon_data(dir: String) -> Array[WeaponData]:
	var files := _open_dir(dir)
	if files.is_empty():
		return []
	var weapons: Array[WeaponData] = []
	weapons.resize(files.size())
	for file in files:
		var weapon: WeaponData = load(dir + "/" + file)
		weapons[weapon.id - 1] = weapon
	return weapons


func _load_character_data(dir: String) -> Array[PlayerCharacterData]:
	var files := _open_dir(dir)
	if files.is_empty():
		return []
	var characters: Array[PlayerCharacterData] = []
	characters.resize(files.size())
	for file in files:
		var character: PlayerCharacterData = load(dir + "/" + file)
		characters[character.id - 1] = character
	return characters


func _load_enemy_data(dir: String) -> Array[EnemyData]:
	var files := _open_dir(dir)
	if files.is_empty():
		return []
	var enemies: Array[EnemyData] = []
	enemies.resize(files.size())
	for file in files:
		var enemy: EnemyData = load(dir + "/" + file)
		if enemies.size() >= enemy.id && enemies[enemy.id - 1] != null:
			printerr("Enemy ID conflict: " + str(enemy.id))
			continue
		enemies[enemy.id - 1] = enemy
		#if !enemy.scene.is_empty():
		#	enemy.loaded_scene = load(enemy.scene)
	return enemies


func _load_item_data(directory: String) -> Array[ItemData]:
	var files := _open_dir(directory)
	var items: Array[ItemData] = []
	items.resize(files.size())
	for file in files:
		var item: ItemData = load(directory + "/" + file)
		var rarity: Enums.Rarity = item.rarity
		if item.icon == null && !item.modifiers.is_empty():
			var id: int = item.modifiers[0].type
			item.icon = get_stat_by_id(id).icon
		items[item.id - 1] = item
	return items


func _load_stat_data(directory: String) -> Array[StatData]:
	var files := _open_dir(directory)
	var stats: Array[StatData] = []
	stats.resize(Enums.StatType.size())
	for file in files:
		var stat: StatData = load(directory + "/" + file)
		if stats[stat.id] != null:
			printerr("Item ID conflict: " + str(stat.id))
		stats[stat.id] = stat
	return stats


func _open_dir(directory: String) -> PackedStringArray:
	var dir := DirAccess.open(directory)
	if dir == null:
		print("No directory %s found" % directory)
		return []
	var files := dir.get_files()
	if files.is_empty():
		printerr("No files found in " + directory)
		return []
	return files


func get_stat_by_id(id: Enums.StatType) -> StatData:
	if id >= stat_info.size():
		return
	var stat := stat_info[id]
	assert(stat.id == id, "Stat ID mismatch, fix your database fool!")
	return stat


func get_item_by_id(id: int) -> ItemData:
	if id > item_data.size():
		return
	return item_data[id - 1]


func get_map_by_id(id: int, value_search: bool = false) -> MapData:
	if value_search:
		var map = map_data.filter(func(data: MapData) -> bool: return data.id == id)
		assert(map.size() < 2, "Non uniqure map id: %d" % id)
		return map
	if map_data.size() < id:
		return null
	return map_data[id - 1]


func get_enemy_by_id(id: int) -> EnemyData:
	if id > enemy_data.size():
		return
	return enemy_data[id - 1]


func get_character_by_id(id: int) -> PlayerCharacterData:
	if id > character_data.size():
		return
	return character_data[id - 1]


func get_weapon_by_id(id: int) -> WeaponData:
	if id > weapon_data.size():
		return
	return weapon_data[id - 1] as WeaponData

#region Utility

## Convert JSON shop item to id for db item
func convert_shopitem_to_entity(shop_data: Dictionary):
	if shop_data.has("identifier"):
		var id: int = 0
		var parts: Array = shop_data.get("identifier").split("_")
		if parts.size() > 1:
			id = int(parts[0])
			match shop_data["itemType"]:
				DataUtility.ITEM_PLAYER:
					assert(id in range(character_data.size()), "Invalid id in identifier")
					var entitiy: PlayerCharacterData = get_character_by_id(id)
					assert(entitiy.full_name == shop_data.name, "Name does not match")
					return entitiy
				DataUtility.ITEM_STAT:
					assert(id in range(item_data.size()), "Invalid id in identifier")
					var entitiy: ItemData = get_item_by_id(id)
					assert(entitiy.full_name == shop_data.name, "Name does not match")
					return entitiy
				_:
					return null
	else:
		Debug.print("No identifier or name found in shop data")
		return null
#endregion
