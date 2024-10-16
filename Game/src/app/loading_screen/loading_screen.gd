class_name LoadingScreen
extends Control

signal loading_completed

@export var shader_precompiler: ShaderPrecompiler
## will still display the loading screen and keep_visible will still work
@export var skip_in_debug: bool = true

var _is_busy: bool = false
var _are_shaders_compiled: bool = false



func start_transition(keep_visible: bool = false) -> void:
	if _is_busy:
		assert(!skip_in_debug, "Should never be busy when skip is true")
		return
		
	visible = true
	if skip_in_debug:
		await get_tree().physics_frame
		loading_completed.emit()
		visible = keep_visible
		return
		
	_is_busy = true
	for enemy in DataService.enemy_data:

		if !ResourceLoader.exists(enemy.scene) || ResourceLoader.has_cached(enemy.scene):
			continue
		var scene: PackedScene = ResourceLoader.load(
			enemy.scene, "PackedScene", ResourceLoader.CACHE_MODE_REUSE
		)
		GameService.add_to_game_cache(scene)

	if JavaScriptBridgeWrapper.is_web():
		# load and cache game scene and map in web and debug builds and load time because we can hide this
		GameService.add_to_game_cache(
			ResourceLoader.load(
				DataService.map_data[0].scene, "PackedScene", ResourceLoader.CACHE_MODE_REUSE
			)
		)
		GameService.add_to_game_cache(
			ResourceLoader.load(
				GameService.GAME_SCENE_PATH, "PackedScene", ResourceLoader.CACHE_MODE_REUSE
			)
		)

	if OS.is_debug_build():
		GameService.clean_cache()

	if !_are_shaders_compiled:
		shader_precompiler.compile_shaders()
		_are_shaders_compiled = true
		await shader_precompiler.shaders_compiled
	
	# * else we cannot await the completed signal in main
	await get_tree().physics_frame
	_is_busy = false
	visible = keep_visible
	loading_completed.emit()
