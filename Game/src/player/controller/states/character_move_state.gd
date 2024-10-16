class_name CharacterMoveState
extends CharacterState

@export var idle_state : CharacterIdleState


func physics_process(_delta) -> CharacterState:
	var _velocity = character.velocity

	var direction: Vector2 = get_direction() 

	if direction.is_zero_approx():
		character.direction.set_next(-1)
		return idle_state

	var axis: = direction.abs().max_axis_index()
	var facing: int
	if axis == Vector2.AXIS_X:
		facing = Directions.WEST if direction.x <= 0 else Directions.EAST	
	elif axis == Vector2.AXIS_Y:
		facing = Directions.NORTH if direction.y <= 0 else Directions.SOUTH
	if facing != null or facing != character.direction.value:
		character.direction.set_next(facing)

	_velocity = _velocity.move_toward(character.movement_speed * direction, character.movement_speed)
	character.set_velocity(_velocity)
	# no delta needed for move_and_slide
	character.move_and_slide()
	return self
