class_name ModifierData
extends Resource

@export	var type: Enums.StatType
@export var mod: Enums.ModType
@export var value: float
@export var is_percentage: bool = false

func get_value_string() -> String:
	var prefix: String = GameSettings.POSITIVE_PREFIX if sign(value) == 1 else GameSettings.NEGATIVE_PREFIX
	return "%s%d%s" % [prefix, value, "%" if is_percentage else GameSettings.NEGATIVE_PREFIX]
