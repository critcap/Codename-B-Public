class_name Hitbox
extends Area2D

const HIT_NOTIFICATION: StringName = &"255174e0-98b8-4707-8118-be7e5a26b5a1"

## Time to wait after the first hit until a second hit can occur
@export var internal_cooldown: float = 0.5

var _icd_timer: Timer
var _is_player_inside: bool = false

func _ready():
	_icd_timer = NodeEx.add_child(Timer.new(), self)
	_icd_timer.autostart = false
	_icd_timer.one_shot = true

func _on_body_entered(body):
	_is_player_inside = true
	if _icd_timer.time_left > 0.0:
		return
	Notifications.notify(HIT_NOTIFICATION, [self.owner, body])
	_icd_timer.start(internal_cooldown)

func _on_body_exited(body):
	_is_player_inside = false

func _physics_process(delta):
	if !_is_player_inside||_icd_timer.time_left > 0.0:
		return
	var player = get_overlapping_bodies()[0] if get_overlapping_bodies().size() > 0 else null
	if player == null:
		return
	# ! only gets player, needs to be expanded when other hitable entities are added
	assert(player is PlayerCharacter)
	_icd_timer.start(internal_cooldown)
	Notifications.notify(HIT_NOTIFICATION, [self.owner, player])
