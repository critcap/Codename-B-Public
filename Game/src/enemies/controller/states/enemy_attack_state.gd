class_name EnemyAttackState
extends EnemyState

const DASH_MULTI: float = 1.5
const MIN_ATTACK_RADIUS: float = 30

@export var move_state: EnemyState
@export var cooldown: float = 0.0

var _dash_progress: float = 0
var _attack_radius: float = 0
var _shape_radius: float = 0
var _has_hit: bool = false
var _dash_angle: Vector2 = Vector2.ZERO

@onready var _timer: Timer = Timer.new()


func _ready() -> void:
	_shape_radius = pow(max(character.collision.shape.radius, MIN_ATTACK_RADIUS), 2.0)
	_attack_radius = (
		_shape_radius
		if character.data.attack_data.type != Enums.AttackType.CHARGE
		else pow(character.data.attack_data.attack_range, 2)
	)
	_timer.one_shot = true
	add_child(_timer)
	_timer.timeout.connect(_on_timer_timeout)


func can_attack(ignore_range: bool = false) -> bool:
	if ignore_range:
		return cooldown <= 0
	return (
		cooldown <= 0
		&& character.global_position.distance_squared_to(player.global_position) <= _attack_radius
	)


func enter() -> void:
	self.update_physics_process = false
	_has_hit = false
	_dash_progress = 0
	cooldown = 999

	if character.data.attack_data.type == Enums.AttackType.CHARGE:
		character.is_signaling_danger.set_next(true)
		character.animation_rig._sprite.material.set_shader_parameter(
			&"is_danger", true
		)
		_timer.start(1.0)
		await _timer.timeout
		character.is_signaling_danger.set_next(false)
		_dash_angle = Vector2.from_angle(
			character.global_position.angle_to_point(player.global_position)
		)
		self.update_physics_process = true
		character.animation_rig._sprite.material.set_shader_parameter(
			&"is_danger", false
		)
		return

	Notifications.notify(EnemyCharacter.ON_HIT_NOTIFICATION, [character, player])
	await get_tree().physics_frame
	get_parent().change_state(move_state)


func exit() -> void:
	_timer.start(character.data.attack_data.cooldown)


func _on_timer_timeout() -> void:
	cooldown = 0


func process(_delta):
	if character.is_signaling_danger.value:
		character.direction.set_next(
			(GameService.get_player().global_position - character.global_position).normalized()
		)
	return self


func physics_process(delta):
	if character.data.attack_data.type == Enums.AttackType.MELEE:
		return self

	if _dash_progress >= character.data.attack_data.dash_duration:
		return move_state

	_dash_progress += delta

	#* Check if the player was hit
	if (
		!_has_hit
		&& player.global_position.distance_squared_to(character.global_position) < _shape_radius
	):
		Notifications.notify(EnemyCharacter.ON_HIT_NOTIFICATION, [character, player])
		_has_hit = true

	var velocity = character.velocity.move_toward(
		character.speed * character.data.attack_data.dash_speed_multi * _dash_angle, character.speed
	)
	character.set_velocity(velocity)
	character.move_and_slide()
	return self
