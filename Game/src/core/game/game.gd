class_name Game
extends Node2D
## The main game class. This class is responsible for managing the game state, and the game loop.

# signals
## emitted when the game session is closed (e.g. the player quits, or the game is over)
signal game_closed(
	victory: bool, items: Array, wave: int, time: int, kills: int, gold: int, score: int
)

var inventory: GameInventory
var stats: GameStats
var context: GameContext
var player: PlayerCharacter
var timer: Timer
var map: Map
var shop: GameShop
#var wave: int = 1
var difficulty: Enums.Difficulty = Enums.Difficulty.EASY

@onready var camera: CameraRig = %CameraRig
@onready var _pause_container: Node2D = %PauseContainer


func _ready():
	Notifications.subscribe(VictorySystem.GAMEOVER_NOTIFICATION, _on_gameover)
	_pause_container.add_child(map, true)
	_pause_container.add_child(player)
	_pause_container.add_child(timer)
	timer.start()
	camera.set_limit(
		map.camera_rect.position.y,
		map.camera_rect.end.x,
		map.camera_rect.end.y,
		map.camera_rect.position.x
	)
	camera.set_target(player)
	context.is_game_paused.value_changed.connect(_on_is_game_paused_changed)
	context.is_started.set_next(true)
	propagate_call("_on_game_ready", [GameService])


func _on_is_game_paused_changed(is_paused: bool, observable) -> void:
	var pause_container: Node = $PauseContainer
	pause_container.process_mode = (
		Node.PROCESS_MODE_DISABLED if is_paused else Node.PROCESS_MODE_INHERIT
	)


# * Process the gameover event
func _on_gameover(is_win: bool) -> void:
	if is_win:
		context.is_gamewon.set_next(true)
		context.current_time = GameSettings.DEFAULT_ROUND_TIME
	else:
		context.is_gameover.set_next(true)
		context.current_time = GameSettings.DEFAULT_ROUND_TIME - timer.time_left
		timer.paused = true
	await get_tree().create_timer(GameSettings.gameover_wait_time).timeout
	player.set_process_mode(Node.PROCESS_MODE_DISABLED)

var is_stopped: = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("magickey_end_game") && OS.is_debug_build():
		close_game()

	if event.is_action_pressed("magickey_toggle_game"):
		is_stopped = !is_stopped
		Engine.time_scale = 0.0 if is_stopped else 1.0

func _on_death_screen_gameover_processed():
	close_game()


func calculate_total_game_score(wave: int, time: int, kills: int) -> int:
	var total_score: = 0
	total_score += (kills * 5)
	total_score += (time * 10)
	total_score += (wave * 100)
	if self.difficulty == Enums.Difficulty.EASY:
		total_score += 100
	elif self.difficulty == Enums.Difficulty.MEDIUM:
		total_score += 300
	elif self.difficulty == Enums.Difficulty.HARD:
		total_score += 600
	elif self.difficulty == Enums.Difficulty.INSANE:
		total_score += 850
	elif self.difficulty == Enums.Difficulty.BALLERN:
		total_score += 1150
	return total_score


func close_game() -> void:
	var items: Array = []
	for item in inventory.get_entire_inventory():
		for i in range(item.count.value):
			items.append(DataUtility.entitiy_to_shop_item(item))

	# prize gold calculation
	var is_win: bool = context.is_gamewon.value
	var prize_gold: float = GameSettings.BASE_PRIZE_GOLD
	if !is_win:
		prize_gold *= context.current_wave / 11.0
	else:
		prize_gold += stats.get_stat(Enums.StatType.LEVEL).value * 10
		prize_gold *= difficulty

	game_closed.emit(
		context.is_gamewon.value,
		items,
		context.current_wave,
		context.current_time,
		context.current_score,
		int(prize_gold),
		self.calculate_total_game_score(
			context.current_wave, context.current_time, context.current_score
		)
	)
