class_name Bullet
extends Area2D

const HIT_NOTIFICATION: StringName = &"44c235b2-89f4-4fdb-a257-ad44e7fa5651"

@export var _data: WeaponData
var bounces = 0
var pierces = 0
var is_returning = false
var attack_range: float

var _random_distance: float = 0
var _travelled_distance: float = 0
var _max_distance_override: float
var _rotation_vector: Vector2
var _shotgun_container: Dictionary

@onready var sprite := %AnimatedSprite2D
@onready var _sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var _collision: CollisionShape2D = %Hitbox

# region rotational methods

func get_bullet_rotation() -> float:
	if _data.is_fixed:
		return _rotation_vector.angle()
	return global_rotation

func get_bullet_vector() -> Vector2:
	if _data.is_fixed:
		return _rotation_vector.normalized()
	return Vector2.from_angle(wrapf(global_rotation, 0.0, TAU))

func set_bullet_rotation(new_rotation: float) -> void:
	if _data.is_fixed:
		_rotation_vector = Vector2.from_angle(new_rotation)
	else:
		global_rotation = new_rotation

func bullet_look_at(target: Vector2) -> void:
	if _data.is_fixed:
		_rotation_vector = Vector2.from_angle(global_position.angle_to_point(target))
	else:
		look_at(target)

# endregion

func set_data(weapon_data: WeaponData, shotgun_map: Dictionary, area: float=1.0, 
	max_range: float=0.0, pos: Vector2=Vector2.ZERO, bullet_rotation: float=0.0) -> void:
	_rotation_vector = Vector2.ZERO
	global_rotation = 0.0
	_data = weapon_data
	_shotgun_container = shotgun_map
	set_bullet_rotation(bullet_rotation)
	_travelled_distance = 0
	_random_distance = 0
	_max_distance_override = Vector2.INF.x
	attack_range = max_range
	bounces = 0
	pierces = 0
	is_returning = false
	_collision.shape.radius = 35 * (_data.hitbox_scale) * area
	_sprite.scale = Vector2.ONE * _data.sprite_scale * area
	sprite.animation = _data.animations
	_sprite.material.set(&"shader_parameter/is_rotation", _data.is_rotating)
	_sprite.material.set(&"shader_parameter/speed", _data.rotation_speed)
	global_position = pos
	set_physics_process(true)
	#_collision.set_deferred(&"disabled", true)
	#show()

func _physics_process(delta: float) -> void:
	var distance = _data.projectile_speed * delta
	if _data.is_fixed:
		global_position += _rotation_vector * distance
	else:
		global_position += transform.x * distance

	_travelled_distance += distance
	_random_distance += distance

	# hit wall kill bullet

	if owner is ProjectileContainer&&!owner.bounds.has_point(global_position):
		if _data.terrain_bounce&&bounces < _data.bounces:
			bounces += 1
			pierces = 0
			_random_distance = 0
			_travelled_distance = 0
			var normal := get_normal_for_enviroment(global_position, owner.bounds)
			global_position = global_position.clamp(owner.bounds.position, owner.bounds.end)
			var direction := get_bullet_vector() - 2 * get_bullet_vector().dot(normal) * normal
			bullet_look_at(global_position + direction)
			return
		_disable()

	if _data.is_random_dir&&_random_distance >= 120.0:
		_random_distance = 0 # Reset travelled distance
		var random_angle := signf(randf() - 0.5) * PI / 4
		set_bullet_rotation(get_bullet_rotation() + random_angle)
		# rotation += random_angle

	if _data.bounces == 999&&_travelled_distance > attack_range:
		_disable()

	# ignore distance when bouncing, piercing
	if bounces > 0&&bounces < _data.bounces:
		return
	# remove if travelled too far
	if _travelled_distance > (_max_distance_override if is_returning else attack_range):
		_disable()

func _on_body_entered(body: Node2D) -> void:
	if !_data.allow_shotgunning&&_shotgun_container.has(body.get_instance_id()):
		return
	
	# TODO try hurt box approach first
	#for i in get_overlapping_bodies():
		#if 
	Notifications.notify(HIT_NOTIFICATION, [self, _data, body])
	if !_data.allow_shotgunning:
		_shotgun_container[body.get_instance_id()] = true

	# ignore anything while returning
	if is_returning:
		return
	# handle bounce
	if bounces < _data.bounces:
		bounces += 1
		pierces = 0
		var next_target: Vector2
		var last_enemy := body as EnemyCharacter
		if GameService.get_enemies().size() > 1||!GameService.get_enemies().has(last_enemy):
			while body == last_enemy:
				last_enemy = GameService.get_enemies().pick_random()
				if is_instance_valid(last_enemy)&&last_enemy != body:
					break
			next_target = last_enemy.global_position
		else:
			next_target = global_position + Vector2.from_angle(TAU * randf())
		_travelled_distance = 0
		bullet_look_at(last_enemy.global_position)
		return
	# handle pierce
	if pierces < _data.pierce:
		pierces += 1
		return
	# handle return
	if _data.return_to_player&&!is_returning:
		is_returning = true
		bullet_look_at(GameService.get_player().global_position)
		# look_at(GameService.get_player().global_position)

		_travelled_distance = 0
		_max_distance_override = (
			global_position.distance_to(GameService.get_player().global_position)
			* GameSettings.RETURNING_PROJECTILE_RANGE_MULTIPLIER
		)
		return
	# * destroy
	_disable()

func _disable() -> void:
	queue_free()

func get_normal_for_enviroment(velocity: Vector2, bounds: Rect2) -> Vector2:
	if velocity.y <= bounds.position.y:
		return Vector2.DOWN
	if velocity.x >= bounds.end.x:
		return Vector2.LEFT
	if velocity.y >= bounds.end.y:
		return Vector2.UP
	# velocity.x <= bounds.position.x:
	return Vector2.RIGHT
