class_name GameContext
extends RefCounted

## Holds the game state and other scene wide variables
## Should only contain data and state that is non essential to the gameplay
## Nodes can get access to this data by adding the  _on_game_ready() method
## as this object gets propagated to all nodes in the scene tree when the game root node is ready 

var is_game_paused: ObservableBool = ObservableBool.new(false)
var is_gameover: ObservableBool = ObservableBool.new(false)
var is_gamewon: ObservableBool = ObservableBool.new(false)
var is_started: ObservableBool = ObservableBool.new(false)
var is_manual_aim: ObservableBool = ObservableBool.new(false)

var current_wave: int = 0
var current_score: int = 0
var current_time: int = 0
