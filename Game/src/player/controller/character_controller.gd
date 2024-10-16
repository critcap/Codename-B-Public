class_name CharacterController
extends StateMachine

@export var character: PlayerCharacter

func _ready():
	Notifications.subscribe(PlayerSystem.PLAYER_DEATH_NOTIFICATION, _on_player_death)
	start()

func _on_player_death():
	process_mode = Node.PROCESS_MODE_DISABLED
