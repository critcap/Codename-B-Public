extends Node

const GAME_SCENE_PATH: String = "res://src/game/Game.tscn"

# * unload these when changed
var _game_scene: PackedScene
var _map_scene: PackedScene
var _cached_entities: Dictionary = {}


var _game: Game
var _map_id: int
var _player_id: int
var _is_game_active: bool = false


func create_game(player_data: PlayerCharacterData,map_data: MapData,start_items: Array = [],difficulty: int = 1) -> Game:
	if _is_game_active:
		return

	if  !ResourceLoader.has_cached(GAME_SCENE_PATH):
		_game_scene = ResourceLoader.load(
			GAME_SCENE_PATH,
			"PackedScene",
			ResourceLoader.CACHE_MODE_REUSE)

	_game = _game_scene.instantiate() as Game
	_is_game_active = true
	_game.player = _create_player(player_data)
	_game.stats = _game.player.stats
	_game.inventory = GameInventory.new()
	_game.timer = Timer.new()
	_game.timer.wait_time = GameSettings.DEFAULT_ROUND_TIME
	_game.timer.one_shot = true
	_game.context = GameContext.new()
	_game.shop = GameShop.new(DataService.item_data, DataService.weapon_data, [player_data.base_weapon])

	# * can cache map because whe only have one map
	if !ResourceLoader.has_cached(map_data.scene):
		_map_scene = ResourceLoader.load(map_data.scene, "PackedScene", ResourceLoader.CACHE_MODE_REUSE)
	_game.map = _map_scene.instantiate() as Map

	_game.difficulty = Enums.Difficulty.values()[difficulty - 1]
	_game.game_closed.connect(_on_game_close)

	# TODO: Stat changes not displayed in stats menu (but dont show them in inventory)
	# apply bought upgrades
	for item in start_items:
		if item is WeaponData || item.modifiers.is_empty():
			continue
		for mod in item.modifiers:
			_game.player.stats.add_mod(mod)

	# add default weapon to character
	_game.player.weapon_rig.add_weapon_from_data(player_data.base_weapon)
	_game.inventory.add_weapon(player_data.base_weapon)
	return _game


func _on_game_close(_a, _b, _c, _d, _e, _f, _g) -> void:
	_game.player.free()
	_game.stats.free()
	_game.inventory.free()
	_game.map.queue_free()
	_game.queue_free()
	_is_game_active = false


func _create_player(player_data: PlayerCharacterData) -> PlayerCharacter:
	_player_id = player_data.id
	var stats := GameStats.new()
	stats.set_stat(Enums.StatType.LEVEL, GameSettings.BASE_LEVEL)
	stats.set_stat(Enums.StatType.MAX_HEALTH, player_data.base_health)
	if !player_data.base_modifiers.is_empty():
		for mod in player_data.base_modifiers:
			stats.add_mod(mod)

	var _player := load(player_data.scene).instantiate() as PlayerCharacter
	_player.stats = stats

	return _player


func get_game() -> Game:
	return _game


func get_player() -> PlayerCharacter:
	return _game.player


func get_player_data() -> PlayerCharacterData:
	assert(
		(
			DataService.character_data.size() < _player_id
			&& DataService.get_character_by_id(_player_id)
		)
	)
	return DataService.get_character_by_id(_player_id)


func get_enemies() -> Array[Node]:
	if OS.is_debug_build():
		for enemy in get_tree().get_nodes_in_group(Group.ENEMY):
			assert(enemy is EnemyCharacter, "Enemy is type of %s" % str(typeof(enemy)))
	return get_tree().get_nodes_in_group(Group.ENEMY)


func get_context() -> GameContext:
	if _game == null:
		return null
	return _game.context


func get_stats() -> GameStats:
	return _game.stats if _game && _game.stats else null


func get_timer() -> Timer:
	return _game.timer


func get_map() -> MapData:
	return DataService.get_map_by_id(_map_id)

## Cache entities for faster loading.
## Only Entities that will be used frequently should be cached.
## Only Entities you know will be used in the game should be cached.
func add_to_game_cache(entity: PackedScene) -> void:
	_cached_entities[entity.resource_path] = entity

func clean_cache() -> void:
	for entity in _cached_entities.values().duplicate():
		assert(ResourceLoader.has_cached(entity.resource_path))
		if !ResourceLoader.has_cached(entity.resource_path):
			_cached_entities.erase(entity.resource_path)
