@icon("res://src/core/shared/suit_hearts_broken.svg")
class_name DamageSystem
extends Node

const DAMAGE_TAKEN_NOTIFICATION = &"067a4840-6f0c-4e0e-bf28-576d046ba8cb"

@export var audio_player: AudioStreamPlayer

var difficulty_dmg_multi: float = 1.0

@onready var _dmg_stat: = GameService.get_stats().get_stat(Enums.StatType.DAMAGE)
@onready var _armor: = GameService.get_stats().get_stat(Enums.StatType.DEFENSE)
@onready var _evasion: = GameService.get_stats().get_stat(Enums.StatType.DODGE)
@onready var _crit: = GameService.get_stats().get_stat(Enums.StatType.CRITICAL_CHANCE)
@onready var _thorns: = GameService.get_stats().get_stat(Enums.StatType.THORNS)


func _ready():
	Notifications.subscribe(Bullet.HIT_NOTIFICATION, _on_bullet_hit)
	Notifications.subscribe(EnemyCharacter.ON_HIT_NOTIFICATION, _on_hitbox_hit)
	difficulty_dmg_multi = Enums.get_difficulty_dmg_multi(GameService.get_game().difficulty)


func _on_bullet_hit(sender: Node, data: WeaponData, target: EnemyCharacter) -> void:
	var health: = target.health
	if !health:
		printerr("target has no health component")
		return
	_apply_damage(data.damage, health)


func _apply_damage(damage_value: float, health: Health) -> void:
	var damage: int = maxi(roundi(damage_value + (damage_value * _dmg_stat.value / 100)),1)
	if randf() <= _crit.value:
		damage *= 2
	health.change_current(-damage)
	Notifications.notify(DAMAGE_TAKEN_NOTIFICATION, [damage, health])


func _on_hitbox_hit(sender: EnemyCharacter, target: PlayerCharacter) -> void:
	if randf() < min(0.6,_evasion.value * 0.01):
		# TODO Dodge
		return
	var enemy_damage: float = (sender.data.damage + sender.data.damage_per_wave * GameService.get_context().current_wave) * difficulty_dmg_multi
	var player_armor: float = 1 / (1 +(_armor.value/15))
	var damage: = maxi(roundi(enemy_damage - 1 * player_armor), 1)
	audio_player.play()
	target.health.change_current(-damage)
	Notifications.notify(DAMAGE_TAKEN_NOTIFICATION, [damage, target.health])

	
	if _thorns.value > 0:
		await get_tree().physics_frame

		var thorns_damage = int(_thorns.value * _crit.value if randf() < _crit.value else _thorns.value)
		if is_instance_valid(sender):
			sender.health.change_current(-thorns_damage)
			Notifications.notify(DAMAGE_TAKEN_NOTIFICATION, [thorns_damage, sender.health])

