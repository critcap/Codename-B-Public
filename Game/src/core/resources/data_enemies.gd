class_name EnemyData
extends Resource

@export var id := 0.0
@export var code := ""
@export var name := ""
@export var description := ""
@export var health := 0.0
@export var health_per_wave := 0.0
@export var speed := 0.0
@export var max_speed := 0.0
@export var acceleration := 0.0
@export var damage := 0.0
@export var damage_per_wave := 0.0
@export var experience := 0.0
@export var drop_change := 0.0
@export var rare_drop := 0.0
@export_file("*.tscn") var scene := ""
@export var attack_data: EnemyAttackData = null
@export var movement_type: Enums.MovementType = Enums.MovementType.CHASE
