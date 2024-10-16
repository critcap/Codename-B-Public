@icon("res://src/core/shared/pawns.svg")
extends Node2D

@export_category("Spawn System")
@export var container: Node2D
@export var DebugDrop: PackedScene
@export_category("Debug")
@export var is_enabled: bool = true

var _spawn_area: Rect2
var _spawn_queue: Array[SpawnWave]
var _spawn_sequencer: Array[SpawnSequenceHandler]

@onready var _wave_timer: Timer = NodeEx.add_child(Timer.new(), self)
@onready var _luck := GameService.get_stats().get_stat(Enums.StatType.LUCK)


func _ready():
	if OS.is_debug_build() && !is_enabled:
		return
	# * disable physics processing
	set_physics_process(false)

	container = container if container else self
	GameService.get_context().is_started.value_changed.connect(_on_game_start)

	Notifications.subscribe(DeathSystem.get_death_notification(Group.ENEMY), _on_enemy_death)
	Notifications.subscribe(VictorySystem.GAMEOVER_NOTIFICATION, _on_gameover)

	_spawn_area = GameService.get_game().map.spawn_rect
	_spawn_area = _spawn_area.grow(-30)
	_spawn_queue = GameService.get_map().spawn_table.timeline.duplicate()
	# reverse because pop_back is faster than pop_front
	_spawn_queue.reverse()
	# TODO add to node
	_wave_timer.one_shot = true
	_wave_timer.timeout.connect(_on_wave_end)


func _on_enemy_death(enemy: EnemyCharacter) -> void:
	var drop_chance = randf()
	randomize()
	if drop_chance < enemy.data.drop_change + (enemy.data.drop_change * _luck.value / 50):
		spawn_pickup_at(enemy.global_position)
	enemy.die(null)


func spawn_pickup_at(pickup_position: Vector2) -> void:
	var pickup_scene := DebugDrop.instantiate() as Node2D
	pickup_scene.position = pickup_position
	self.call_deferred(&"add_child", pickup_scene)


func _on_game_start(is_started: bool, _obs) -> void:
	if OS.is_debug_build() && !is_enabled:
		return
		
	if !is_started:
		return
	var wave: SpawnWave = _spawn_queue.pop_back()
	_wave_timer.start(wave.duration)

	for sequence in wave.sequences:
		if !sequence.is_enabled:
			assert(false)
		_spawn_sequencer.append(SpawnSequenceHandler.new(sequence, _spawn_area, container))

	set_physics_process(true)


func _on_wave_end() -> void:
	for handler in _spawn_sequencer:
		handler.free()
	_spawn_sequencer.clear()
	if _spawn_queue.is_empty():
		return

	GameService.get_context().current_wave += 1
	set_physics_process(false)
	var player := GameService.get_player()
	if player.health.current == player.health.maximum:
		Notifications.notify(
			PlayerExperience.LEVEL_UP_NOTIFICATION,
			[player.experience.level + 1, player.experience.experience]
		)
	else:
		spawn_pickup_at(Vector2.ZERO)
	if _spawn_queue[-1] == null:
		GameService.get_timer().stop()
		GameService.get_timer().start(0.2)
		return
	await get_tree().create_timer(_spawn_queue[-1].transition).timeout
	var wave: SpawnWave = _spawn_queue.pop_back()
	set_physics_process(true)
	_wave_timer.start(wave.duration)

	for sequence in wave.sequences:
		if (
			!sequence.is_enabled
			|| (
				Enums.Difficulty.values()[sequence.difficulty - 1]
				> GameService.get_game().difficulty
			)
		):
			continue
		_spawn_sequencer.append(SpawnSequenceHandler.new(sequence, _spawn_area, container))


func _on_gameover(_group) -> void:
	set_physics_process(false)
	_spawn_queue.clear()


func _physics_process(delta: float) -> void:
	if _spawn_sequencer.is_empty():
		print("No Sequences in current wave")
		return

	for handler in _spawn_sequencer:
		handler.process_spawns(delta)


class SpawnSequenceHandler:
	extends Object
	## current spawn sequence
	var _sequence: SpawnSequence
	## bounds for the spawnable area
	var _bounds: Rect2
	## internal tracker for the spawn intervalls
	var _interval_count: float = 0.0
	## Queue of positions where entities can spawn
	var _queue: Array[Vector2]
	## Parent 2D Node in which the entities will be spawned
	var _container: Node2D
	## rotation

	func _init(sequence: SpawnSequence, bounds: Rect2, container: Node2D) -> void:
		_sequence = sequence
		_bounds = bounds.grow(-2)
		_container = container

	func process_spawns(delta: float) -> void:
		if !_queue.is_empty():
			var entity := load(_sequence.entity.scene).instantiate() as Node2D
			entity.data = _sequence.entity
			entity.global_position = _queue.pop_back()
			if _container.get_children().size() > GameSettings.ENEMY_ENTITY_LIMIT:
				_container.get_child(0).queue_free()
			_container.call_deferred(&"add_child", entity)
			entity.call_deferred(&"setup")
			# returning here to avoid that the current batch will not be mixed with the next
			return

		if _interval_count < _sequence.interval:
			_interval_count += delta
			return
		_interval_count = 0.0

		if _sequence.pattern.offsets.size() <= 1:
			for i in range(_sequence.count):
				var pos := _bounds.size / -2
				pos.x += randf_range(
					_sequence.pattern.radius, _bounds.size.x - _sequence.pattern.radius
				)
				pos.y += randf_range(
					_sequence.pattern.radius, _bounds.size.y - _sequence.pattern.radius
				)
				pos += Vector2.ZERO
				if !_bounds.has_point(pos):
					pos = pos.clamp(_bounds.position, _bounds.end)
				_queue.append(pos)
			return

		var pos := _bounds.size / -2
		pos.x += randf_range(_sequence.pattern.radius, _bounds.size.x - _sequence.pattern.radius)
		pos.y += randf_range(_sequence.pattern.radius, _bounds.size.y - _sequence.pattern.radius)
		pos += Vector2.ZERO

		for i in range(_sequence.count):
			var offset: Vector2 = (
				_sequence.pattern.offsets.pick_random()
				if _sequence.pattern.random_offset
				else _sequence.pattern.offsets[i]
			)
			pos += offset
			if !_bounds.has_point(pos):
				pos = pos.clamp(_bounds.position, _bounds.end)
			_queue.append(pos)
