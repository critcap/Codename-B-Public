class_name EnemyAttackData
extends Resource

## cooldown for the attack in seconds
@export var cooldown: float = 1.0
@export var attack_range: int = 10
@export var type: Enums.AttackType = Enums.AttackType.MELEE
@export var dash_duration: float = 0.5
@export var dash_speed_multi: float = 1.5
