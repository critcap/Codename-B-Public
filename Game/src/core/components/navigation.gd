@icon("res://src/core/shared/flag_triangle.svg")
class_name Navigation
extends Node
# This is a simple script that returns the direction to the _player.

## If true, the enemy will follow the global _player
@export var follow_global_player: bool = true
## range at which the enemy will stop moving
@export var deadzone: int = 50:
	set(value):
		deadzone = value
		_deadzone_squared = deadzone * deadzone
	get:
		return deadzone
@export var flee_range: int = 100:
	set(value):
		flee_range = value
		_flee_range_squared = flee_range * flee_range

var _flee_range_squared: int = flee_range * flee_range
var _deadzone_squared: int = deadzone * deadzone
var _current_target: Vector2 = Vector2.ZERO
var _player: Node2D
var _map_rect: Rect2

@onready var _character := owner as EnemyCharacter if owner != null else null


func _ready() -> void:
	if GameService.get_game() == null:
		return
	_map_rect = GameService.get_game().map.spawn_rect
		
	_map_rect.grow(-deadzone)
	if _character.data.movement_type == Enums.MovementType.ROAM:
		_current_target.x = randf_range(_map_rect.position.x + 50, _map_rect.end.x - 50)
		_current_target.y = randf_range(_map_rect.position.y + 50, _map_rect.end.y - 50)

func get_direction_to_target(can_attack: bool = false) -> Vector2:
	if _player == null && GameService.get_player() != null:
		_player = GameService.get_player()
	if (
		_character == null
		or _player == null
		or _character.data.movement_type == Enums.MovementType.STATIONARY
		or (
			_player.global_position.distance_squared_to(_character.global_position)
			< _deadzone_squared
		)
	):
		return Vector2.ZERO

	if _character.data.movement_type == Enums.MovementType.ROAM:
		return roam()
	if _character.data.movement_type == Enums.MovementType.FLEE:
		if _player.position.distance_squared_to(_character.global_position) < _flee_range_squared:
			return _player.global_position * -1
		return roam()
	if _character.data.movement_type == Enums.MovementType.DRIVE_BY:
		if !can_attack:
			roam()
	return _player.position


func roam() -> Vector2:
	if _character.global_position.distance_squared_to(_current_target) < _deadzone_squared:
		_current_target.x = randf_range(_map_rect.position.x + 50, _map_rect.end.x - 50)
		_current_target.y = randf_range(_map_rect.position.y + 50, _map_rect.end.y - 50)
	return _current_target
