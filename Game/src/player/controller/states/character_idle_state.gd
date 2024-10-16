class_name CharacterIdleState
extends CharacterState

@export var move_state: CharacterState

func enter() -> void:
	super.enter()
	character.velocity = Vector2.ZERO

func physics_process(_delta: float) -> CharacterState:
	if get_direction() == Vector2.ZERO:
		return self
	return move_state
