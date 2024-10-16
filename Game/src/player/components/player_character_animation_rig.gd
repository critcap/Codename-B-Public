extends Node2D

const NORTH: StringName = &"north"
const SOUTH: StringName = &"south"
const EAST: StringName = &"east"
const WEST: StringName = &"west"

@export var character: PlayerCharacter
@export var health: Health

@onready var sprite: AnimatedSprite2D = %AnimatedSprite
@onready var effect_animations: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	health.health_changed.connect(_on_health_health_changed)
	character.direction.value_changed.connect(_on_direction_value_changed)

func _on_health_health_changed(value) -> void:
	effect_animations.play(&"player_character_damage")

func _on_direction_value_changed(value: int, _oberservable) -> void:
	if value == -1:
		sprite.stop()
		return
	sprite.play(Directions.to_string_name(value))
