extends Control

@export var pause_menu: Control

@onready var music_slider = %MusicSlider
@onready var sfx_slider = %SfxSlider
@onready var save_button = %Save
@onready var cancel_button = %Cancel

var initial_music_volume: float
var initial_sfx_volume: float


func _ready():
	save_button.connect("pressed", Callable(self, "_on_save_pressed"))
	cancel_button.connect("pressed", Callable(self, "_on_cancel_pressed"))
	pause_menu.settings_pressed.connect(_on_settings_pressed)
	
func _on_settings_pressed() -> void:
	initial_music_volume = music_slider.value
	initial_sfx_volume = sfx_slider.value
	show()
	
func _on_save_pressed():
	hide()
	
func _on_cancel_pressed():
	music_slider.value = initial_music_volume
	sfx_slider.value = initial_sfx_volume
	hide()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") && visible:
		hide()
		get_viewport().set_input_as_handled()
