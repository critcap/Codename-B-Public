class_name PlayerCharacterData
extends Resource

@export var name := ""
@export var id := 0
@export var full_name := ""
@export var description := ""
@export var price := 0
@export var thumbnail := ""
@export var base_health := 0
@export var scene := ""
@export var base_weapon: WeaponData = null
@export var base_modifiers: Array[ModifierData] = []
@export var max_count: int = 1
