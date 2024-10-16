class_name EnemyFollowState
extends EnemyState

@export var attack_state: EnemyAttackState
@export var movement_type: Enums.MovementType


func physics_process(delta: float) -> State:
	var direction: Vector2 = character.navigation.get_direction_to_target(
		attack_state.cooldown <= 0.0
	)

	if character.data.acceleration != 0.0:
		character.speed += character.data.acceleration * delta


	if attack_state.can_attack():
		return attack_state

	var velocity: Vector2
	if direction != Vector2.ZERO:
		direction = direction - character.global_position
		# * set character direction
		character.direction.set_next(direction.normalized())
		velocity = character.velocity.move_toward(
			character.speed * direction.normalized(), character.speed
		)
	else:
		velocity = direction
	character.set_velocity(velocity)
	character.move_and_slide()
	return self
