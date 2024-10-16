extends Control

signal start_game(player: PlayerCharacterData)

@export var entry_scene: PackedScene
@onready var button: = %Button
@onready var body: = %Body
@onready var status: = %StatusMessage

var has_selected: bool  : 
	set(value):
		has_selected = value
		button.disabled = !value
		
var index: int = -1
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if JavaScriptBridgeWrapper.is_web():
		status.show()
		button.visible = OS.is_debug_build()
		body.hide()
		return
	
	button.pressed.connect(func():
		start_game.emit(DataService.get_character_by_id(index))
		)
	for character in DataService.character_data:
		var entry: = entry_scene.instantiate()
		body.add_child(entry)
		entry.button.toggled.connect(func(on):
			for child in body.get_children():
				if child == entry:
					has_selected = on
					if on:
						index = body.get_children().find(child) +1
						button.grab_focus()
					continue
				child.button.set_pressed_no_signal(false)
			)
		entry.refresh(character)
	body.get_child(0).button.grab_focus()
		

func set_status(message: String) -> void:
	status.text = message
