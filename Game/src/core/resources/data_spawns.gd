class_name SpawnSequence
extends Resource


# Entity to spawn
@export var entity : EnemyData
# Name of the entity to spawn. Can be ignored
@export var entity_name := ""
# 
@export var type := 0
@export var wave := 0
@export var difficulty : = 0
@export var pattern : SpawnPattern
@export var delay := 0
@export var interval := 0
@export var interval_min := 0
@export var count := 0
@export var increase := 0
@export var is_enabled := false
