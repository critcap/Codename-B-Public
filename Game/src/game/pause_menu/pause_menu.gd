extends Control

signal settings_pressed
signal end_pressed
signal continue_pressed

@onready var settings_button = %SettingsButton
@onready var end_button = %EndButton
@onready var continue_button = %ContinueButton

func _ready() -> void:
	settings_button.pressed.connect(_on_settings_pressed)
	end_button.pressed.connect(_on_end_pressed)
	continue_button.pressed.connect(_on_continue_pressed)

func _on_game_ready(service: GameService) -> void:
	draw.connect(func() -> void:
		GameService.get_context().is_game_paused.set_next(true))
	hidden.connect(func() -> void:
		GameService.get_context().is_game_paused.set_next(false))

func _input(event) -> void:
	if event.is_action_pressed(KeyBinds.TOGGLE_PAUSE_MENU) || event.is_action_pressed("open_pause_menu"):
		if GameService.get_context().is_gameover.value || GameService.get_context().is_gamewon.value:
			set_process_input(false)
			return
		_toggle_pause_menu()

func _on_settings_pressed() -> void:
	settings_pressed.emit()

func _on_end_pressed() -> void:
	GameService.get_game().close_game()

func _on_continue_pressed() -> void:
	_toggle_pause_menu()

func _toggle_pause_menu() -> void:
	visible = !visible
	GameService.get_context().is_game_paused.set_next(visible)
