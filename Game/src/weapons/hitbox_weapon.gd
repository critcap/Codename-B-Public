class_name HitboxWeapon
extends Area2D

@export var data: WeaponData

var aoe_range: float:
	set(value):
		shape.shape.radius = 165 * (1 + value / 100)
		sprite.scale = 10 + value / 100
		aoe_range = value

var _icd: float = 0.0
@onready var shape: CollisionShape2D = %CollisionShape2D
@onready var sprite := %AnimatedSprite2D
@onready var _dummy: Bullet = Bullet.new()


func _on_body_entered(body):
	Notifications.notify(Bullet.HIT_NOTIFICATION, [_dummy, data, body])
	GameService.get_stats().get_stat(Enums.StatType.AREA).bind(self, &"aoe_range", true)


func _physics_process(delta):
	if _icd > data.attack_speed:
		_icd = 0.0
		var enemies := get_overlapping_bodies()
		if enemies.is_empty():
			return
		for body in enemies:
			if is_instance_valid(body):
				Notifications.notify(Bullet.HIT_NOTIFICATION, [self, data, body])
				await get_tree().physics_frame
	_icd += delta
