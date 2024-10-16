@icon("res://src/core/shared/skull.svg")
class_name DeathSystem
extends Node

const DEATH_NOTIFICATION: StringName = &"05a9d8a1-6c27-457b-b375-1fa27f58e88e"

func _ready():
	Notifications.subscribe(DamageSystem.DAMAGE_TAKEN_NOTIFICATION, _on_damage_taken)

func _on_damage_taken(damage: int, health: Health) -> void:
	if health.current <= 0:

		if not health is PlayerHealth:
			GameService.get_context().current_score += 1
			
		var notification_string = Group.PLAYER if health is PlayerHealth else Group.ENEMY
		Notifications.notify(DeathSystem.get_death_notification(notification_string), [health.owner])


static func get_death_notification(group: String) -> StringName:
	return StringName(str(DEATH_NOTIFICATION + group))
