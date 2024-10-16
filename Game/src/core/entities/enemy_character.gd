class_name EnemyCharacter
extends CharacterBody2D

## Argument 1: EnemyCharacter, Argument 2: PlayerCharacter
const ON_HIT_NOTIFICATION: StringName = &"27858603-7184-43fd-9edb-c393df592278"

@export var animation_rig: EnemyCharacterAnimationRig
@export var data: EnemyData
@export var movement: Enums.MovementType = Enums.MovementType.CHASE
@export var collision: CollisionShape2D

var direction: ObservableVector2 = ObservableVector2.new(Vector2.ZERO)
var is_signaling_danger: ObservableBool = ObservableBool.new(false)
var speed: float = 0.0

@onready var health: Health = $%Health
@onready var navigation: Navigation = $%Navigation
@onready var audio_player: AudioStreamPlayer = %SfxDeath


func setup() -> void:
	if data.speed == data.max_speed || sign(data.acceleration) > 0:
		speed = data.speed
	else:
		speed = randf_range(data.speed, data.max_speed)

	health.maximum = round(
		data.health + (data.health_per_wave * GameService.get_context().current_wave)
	)
	health.current = health.maximum

	Notifications.subscribe(VictorySystem.GAMEOVER_NOTIFICATION, die)
	animation_rig.setup(self)

func die(_arg) -> void:
	var tween := get_tree().create_tween()
	if !GameService.get_context().is_gameover.value && !GameService.get_context().is_gamewon.value:
		audio_player.play()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	tween.tween_callback(func(): queue_free())
