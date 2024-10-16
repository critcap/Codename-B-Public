extends Node

var music_volume: float = 0.1
var sfx_volume: float = 0.1


# Called when the node enters the scene tree for the first time.
func _ready():
	var music_bus_index = AudioServer.get_bus_index("Music") 
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(music_volume))
	var sfx_bus_index = AudioServer.get_bus_index("Sfx") 
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(sfx_volume))

