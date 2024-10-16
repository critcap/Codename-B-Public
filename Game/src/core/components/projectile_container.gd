@icon("res://src/core/shared/target.png")
class_name ProjectileContainer
extends Node2D


@export var bullet_scene: PackedScene

@onready var bounds = GameService.get_game().map.spawn_rect
@onready var _area := GameService.get_stats().get_stat(Enums.StatType.AREA)
@onready var _range = GameService.get_stats().get_stat(Enums.StatType.RANGE)
@onready var _player := GameService.get_player()

#var _bullet_pool: Array[Bullet] = []


func _ready():
	bullet_scene = bullet_scene if bullet_scene else load("res://src/weapons/BulletBase.tscn")
	Notifications.subscribe(ProjectileEmitter.EMIT_NOTIFICATION, _on_emit_request)


func _get_projectiles() -> Bullet:
#	if _bullet_pool.is_empty():
	var projectile := bullet_scene.instantiate() as Bullet
	#	projectile.visibility_changed.connect(func() -> void:
	#		_bullet_pool.append(projectile)
	#	)
	#	projectile.global_position = Vector2.ZERO
	add_child(projectile)
	projectile.owner = self
	return projectile
	#else:
	#	return _bullet_pool.pop_back()


func _on_emit_request(_position: Vector2, _rotation: float, _data: WeaponData) -> void:
	# it is required to have a shotgun container to store the shotgun bullets
	var shotgun_container: = {}

	if _data.pattern == WeaponData.Pattern.CONE:
		var angle_step = 10 * PI / 180  # 10 degrees in radians
		var count = _data.count
		var center_index = (count - 1) / 2.0  # Calculate the center index for even splitting
		for i in range(_data.count):
			var projectile := _get_projectiles()
			var proj_rotation = _rotation + angle_step * (i - center_index)
			projectile.set_data(
				_data,
				shotgun_container,
				_data.size_multiplier + _area.value / 100,
				_data.attack_range + _range.value,
				_position,
				proj_rotation
			)

	elif _data.pattern == WeaponData.Pattern.CIRCLE:
		var base_rotation = TAU / randi_range(1, 12)
		for i in range(_data.count):
			_position = _player.global_position
			if _data.delay != 0:
				await get_tree().physics_frame
			var projectile := _get_projectiles()
			var proj_rotation = base_rotation + i * 2 * PI / _data.count
			projectile.set_data(
				_data,
				shotgun_container,
				_data.size_multiplier + _area.value / 100,
				_data.attack_range + _range.value,
				_position,
				proj_rotation
			)

	elif _data.pattern == WeaponData.Pattern.RANDOM:
		for i in range(_data.targets):
			var projectile := _get_projectiles()
			_position = _player.global_position
			_rotation = randf() * TAU
			projectile.set_data(
				_data,
				shotgun_container,
				_data.size_multiplier + _area.value / 100,
				_data.attack_range + _range.value,
				_position,
				_rotation
			)
			await get_tree().create_timer(_data.delay).timeout
