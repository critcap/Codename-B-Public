class_name ProjectileEmitter
extends Marker2D

const EMIT_NOTIFICATION: StringName = &"90b5554f-641c-4cdf-b4a5-9190c35a442a"


func _on_weapon_base_shot(_rotation: float, _data: WeaponData):
	Notifications.notify(EMIT_NOTIFICATION, [global_position, _rotation, _data])
