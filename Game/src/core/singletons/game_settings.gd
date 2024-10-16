extends Node

const BASE_LEVEL: int = 1
const ENEMY_ENTITY_LIMIT: int = 100
const DEFAULT_ROUND_TIME: int = 900
const POSITIVE_PREFIX: String = "+"
const NEGATIVE_PREFIX: String = ""
const BASE_DROP_CHANCE: float = 0.01
const PIERCE_RANGE_MULTIPLIER: float = 1.25
const MAX_INT: int = 9223372036854775807
const BASE_PRIZE_GOLD: int = 1000
## Weapons
const RETURNING_PROJECTILE_RANGE_MULTIPLIER: float = 1.25
const PLAYER_SPAWN_DEADZONE: int = 50
const CRITICAL_DAMAGE_MULIT: float = 2.0
## Inventory
const DEFAULT_UPGRADE_COUNT: int = 3
const MAX_WEAPONS: int = 4

var _player_spawn_deadzone_squared: float = -1
var PLAYER_SPAWN_DEADZONE_SQUARED: float:
	get:
		if is_equal_approx(_player_spawn_deadzone_squared, -1):
			_player_spawn_deadzone_squared = pow(PLAYER_SPAWN_DEADZONE, 2)
		return _player_spawn_deadzone_squared


var gameover_wait_time: float:
	get:
		return 1.0


func calculate_required_experience(level: int) -> int:
	return int(pow(level + 3, 2))
