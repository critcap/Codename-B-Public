class_name StateMachine
extends Node

signal state_changed(state)

var _current_state: State
var _is_transitioning: bool = false

func change_state(state: Node) -> void:
	_change_state(state)

func _change_state(state: Node) -> void:
	if !state:
		push_error("State cannot be null")
		return
	if _current_state == state || _is_transitioning:
		return

	_is_transitioning = true
	if _current_state:
		_current_state.exit()
	
	_current_state = state
	_current_state.enter()
	_is_transitioning = false
	state_changed.emit(_current_state)

func start(initial_state: State = null) -> void:
	if initial_state:
		_change_state(initial_state)
	elif get_child_count() > 0:
		_change_state(get_child(0))
	else:
		push_error("No initial state provided and no children found")

func _unhandled_input(event):
	if _current_state && _current_state.update_unhandled_input:
		_change_state(_current_state.unhandled_input(event))

func _physics_process(delta):
	if _current_state && _current_state.update_physics_process:
		_change_state(_current_state.physics_process(delta))

func _process(delta):
	if _current_state && _current_state.update_process:
		_change_state(_current_state.process(delta))
