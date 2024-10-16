class_name ShaderPrecompiler
extends Node2D
## Compile shaders of all CanvasItems before the game runs
## Displays all items, weapons, enemies and characters for a short time to compile their shaders
## Should only to be used when the game is started for the first time

signal shaders_compiled

## Precompile shaders before new game session
@export var precompile_shaders: bool = true
## Precompile shaders when the game loads.
## When false the compilation will be done after character selection
@export var precompile_at_startup: bool = true

## Observable with the current loading message
var load_message: ObservableString = ObservableString.new("")
## Observable with the current loading progress range 0 - 100.0
var progress: ObservableFloat = ObservableFloat.new(0.0)
var pos: Marker2D

# compilation members
@onready var texture_rect: TextureRect = NodeEx.add_child(TextureRect.new(), self)
@onready var camera: Camera2D = NodeEx.add_child(Camera2D.new(), self)


## Compile shaders of all CanvasItems before the game runs
## This should remove all microstutters caused by shader compilation while playing the game
## When compiling at load time all CanvasItems will be precompiled instead of only the selected.
func compile_shaders() -> void:
	show()
	pos = NodeEx.add_child(Marker2D.new(), self)
	camera.enabled = true
	#self.process_mode = Node.PROCESS_MODE_DISABLED
	var step: float = 10.0 / DataService.stat_info.size()
	texture_rect.show()
	load_message.set_next(tr("LOADING_ITEMS"))
	for i in DataService.stat_info:
		if i == null:
			continue
		texture_rect.texture = i.icon
		await get_tree().physics_frame
		progress.set_next(progress.value + step)

	step = 10.0 / DataService.item_data.size()
	for item in DataService.item_data:
		texture_rect.texture = item.icon
		await get_tree().physics_frame
		progress.set_next(progress.value + step)

	step = 20.0 / DataService.weapon_data.size()
	load_message.set_next(tr("LOADING_WEAPONS"))
	for weapon in DataService.weapon_data:
		if weapon.scene != null:
			var scene = weapon.scene.instantiate()
			scene.data = weapon
			pos.add_child(scene)
			await get_tree().create_timer(1.0).timeout
			scene.call_deferred(&"queue_free")
		else:
			var bullet_scene: Node2D = load("res://src/weapons/BulletBase.tscn").instantiate()
			pos.add_child(bullet_scene)
			bullet_scene.set_physics_process(false)
			bullet_scene.set_data(weapon, {}, 1.0, 1000)
			await get_tree().physics_frame

		texture_rect.texture = weapon.icon
		await get_tree().physics_frame
		progress.set_next(progress.value + step)

	texture_rect.hide()

	load_message.set_next(tr("LOADING_MAP"))
	# when there are more than 1 map, this should be done after map selection
	step = 20.0
	var map := load(DataService.map_data[0].scene).instantiate() as Map
	pos.add_child(map)
	await get_tree().physics_frame
	# to render the the whole map because
	# I have no idea how godots culling or chunking for TileMaps work
	camera.zoom = Vector2.ONE * 0.5
	await get_tree().physics_frame
	camera.zoom = Vector2.ONE
	map.queue_free()
	progress.set_next(progress.value + step)

	load_message.set_next(tr("LOADING_CHARACTERS"))
	step = 20.0 / DataService.enemy_data.size()
	for enemy in DataService.enemy_data:
		if !ResourceLoader.exists(enemy.scene):
			continue
		var data := load(enemy.scene)
		if data == null:
			continue
		var scene := data.instantiate() as EnemyCharacter
		scene.data = enemy
		pos.add_child(scene)
		scene.process_mode = Node.PROCESS_MODE_DISABLED
		scene.set_physics_process(false)
		scene.set_physics_process_internal(false)
		scene.set_process(false)
		var sprite := (
			scene.get_node("EnemyCharacterAnimationRig/Pivot/AnimatedSprite") as AnimatedSprite2D
		)
		var anim = scene.get_node("EnemyCharacterAnimationRig")
		sprite.visible = true
		anim.visible = true
		await get_tree().physics_frame
		# * calling private method but thats okay here
		anim._on_health_health_changed(2.0)
		var frame_count: int = 0
		for animation in sprite.sprite_frames.get_animation_names():
			frame_count += sprite.sprite_frames.get_frame_count(animation)
		for i in range(frame_count):
			sprite.frame = i
			await get_tree().physics_frame
		scene.free()
		progress.set_next(progress.value + step)

	var characters_to_load := []
	# only load the selected player when not compiling at load time
	if precompile_at_startup:
		characters_to_load = DataService.character_data
	else:
		characters_to_load.append(GameService.get_player_data())

	#step = 20.0 / characters_to_load.size()
	#for player in characters_to_load:
	#var data := load(player.scene)
	#if data == null:
	#continue
	#var scene := data.instantiate() as PlayerCharacter
	#add_child(scene)
	#var anim = scene.get_node("PlayerCharacterAnimationRig")
	#anim.sprite.visible = true
	#anim.visible = true
	#await get_tree().physics_frame
	## * calling private method but thats okay here
	#anim._on_health_health_changed(2.0)
	#var frame_count: int = 0
	#for animation in anim.sprite.sprite_frames.get_animation_names():
	#frame_count += anim.sprite.sprite_frames.get_frame_count(animation)
	#for i in range(frame_count):
	#anim.sprite.frame = i
	#await get_tree().physics_frame
	#scene.call_deferred(&"queue_free")
	#progress.set_next(progress.value + step)

	pos.free()
	camera.enabled = false
	hide()
	shaders_compiled.emit()
