@icon("res://src/core/shared/crown_b.svg")
class_name VictorySystem
extends Node

@export var victory_music_player: AudioStreamPlayer
@export var defeat_music_player: AudioStreamPlayer
@export var bg_music_player: AudioStreamPlayer

const GAMEOVER_NOTIFICATION: StringName = &"86c7134c-4a8a-4788-b080-06e692ccd424"

func _ready() -> void:
	Notifications.subscribe(
		DeathSystem.get_death_notification(Group.PLAYER), _on_player_death)
	GameService.get_timer().timeout.connect(_on_timeout)
	

func _on_player_death(player: Node2D) -> void:
	Notifications.notify(GAMEOVER_NOTIFICATION, [false])
	bg_music_player.stop()
	defeat_music_player.play()

func _on_timeout() -> void:
	Notifications.notify(GAMEOVER_NOTIFICATION, [true])
	bg_music_player.stop()
	victory_music_player.play()
