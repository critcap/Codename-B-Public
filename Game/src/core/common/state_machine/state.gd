class_name State
extends Node

var update_process: bool = true
var update_physics_process: bool = true
var update_unhandled_input: bool = true

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta: float) -> State:
	return self

func unhandled_input(_event: InputEvent) -> State:
	return self

func physics_process(_delta: float) -> State:
	return self