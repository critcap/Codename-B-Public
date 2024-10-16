extends MarginContainer

@onready var button: = %Button
@onready var icon: = %TextureRect
@onready var _name: = %Name
@onready var description: = %Description
# Called when the node enters the scene tree for the first time.
func refresh(data: PlayerCharacterData) -> void:
	icon.texture = load(data.thumbnail)
	_name.text = data.full_name
	description.text = data.description
	
	
