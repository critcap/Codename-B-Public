class_name EnemyController
extends StateMachine

@export var start_state: EnemyState
@export var character: EnemyCharacter

func _ready():
	start(start_state)
