class_name EnemyState
extends State

var character : EnemyCharacter :
	get:
		return (get_parent() as EnemyController).character

var player: PlayerCharacter:
	get:
		if !_player:
			_player = GameService.get_player()
		return _player

var _player: PlayerCharacter