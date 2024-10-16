class_name ObservableFloat
extends Observable

func _init(initial: float = 0.0):
	_value = initial

func set_value(new_value: float) -> void:
	super.set_next(new_value)