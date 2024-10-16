class_name PlayerCharacter
extends CharacterBody2D

# bindings
@export var base_movement_speed: int = 300
@export var experience: PlayerExperience
@export var weapon_rig: WeaponRig
@export var health: PlayerHealth

var movement_speed: int 

var direction: ObservableInt = ObservableInt.new(0)
var stats: GameStats


func _ready() -> void:
	var ms = stats.get_stat(Enums.StatType.MOVE_SPEED)
	stats.get_stat(Enums.StatType.MOVE_SPEED).value_changed.connect(_set_movement_speed)
	#health.set_maximum(stats.get_stat(Enums.StatType.MAX_HEALTH).value)
	health.current = health.maximum
	_set_movement_speed(stats.get_stat(Enums.StatType.MOVE_SPEED).value)


func is_moving() -> bool:
	return velocity.length_squared() > 0

func _set_movement_speed(value: float) -> void:
	movement_speed = int(base_movement_speed + base_movement_speed * (value / 100))
