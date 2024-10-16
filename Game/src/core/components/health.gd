@icon("res://src/core/shared/suit_hearts.svg")
class_name Health
extends Node

signal health_changed(value: int)

var maximum: int = 0
var current: int = 0


# Set the current health to a value, clamping it to the maximum
func set_current(value: int):
	current = mini(maximum, value)
	health_changed.emit(current)

# Change the current health by an amount, clamping it to the maximum
func change_current(amount: int):
	set_current(current + amount)