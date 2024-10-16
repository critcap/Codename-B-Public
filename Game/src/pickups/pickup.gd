class_name Pickup
extends Area2D

signal picked_up

@export var heal_amount: int = 20

const PICKED_UP_NOTIFICATION: StringName = &"dc780b5d-90a5-4dc7-b895-9399e0338551"


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	assert(body is PlayerCharacter)
	if body is PlayerCharacter:
		Notifications.notify(PICKED_UP_NOTIFICATION, [heal_amount])
		queue_free() 
