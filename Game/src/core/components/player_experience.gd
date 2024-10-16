class_name PlayerExperience
extends Node

const LEVEL_UP_NOTIFICATION = &"8d332ff7-3a73-4a5f-a32e-9fa9f26a6bb2"
const EXP_GAINED_NOTIFICATION = &"5bef6550-5d10-41f1-bbcd-93529e981d09"

## Current player level
var level: int :
	get:
		return _level

var _level: int = GameSettings.BASE_LEVEL 

## Current experiences collected by the player
var experience: int :
	get:
		return _experience
var _experience: int = 0

## required experience to level up
var required_exp: int = 0


func _ready() -> void:
	required_exp = GameSettings.calculate_required_experience(GameSettings.BASE_LEVEL)
	Notifications.subscribe(DeathSystem.get_death_notification(Group.ENEMY), _on_enemy_death)

func _on_enemy_death(_enemy) -> void:
	# TODO remove hardcoded value with _enemy.experience
	var amount: int = 2
	_experience += _enemy.data.experience
	Notifications.notify(EXP_GAINED_NOTIFICATION, [_experience])

	if _experience < required_exp:
		return

	while _experience >= required_exp:
		_experience -= required_exp
		required_exp = GameSettings.calculate_required_experience(_level + 1)
		_level += 1
		Notifications.notify(LEVEL_UP_NOTIFICATION, [_level, _experience])

	Notifications.notify(EXP_GAINED_NOTIFICATION, [_experience])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"magickey") && OS.is_debug_build():
		Notifications.notify(LEVEL_UP_NOTIFICATION, [_level +1, _experience])