class_name CharacterState
extends State

var character: PlayerCharacter:
	get:
		return (owner as CharacterController).character

var stats: GameStats:
	get:
		return character.stats

# Returns input direction as a Vector2
func get_direction() -> Vector2:
	return Input.get_vector(
		KeyBinds.PLAYER_MOVE_LEFT, 
		KeyBinds.PLAYER_MOVE_RIGHT,
		KeyBinds.PLAYER_MOVE_UP, 
		KeyBinds.PLAYER_MOVE_DOWN)
