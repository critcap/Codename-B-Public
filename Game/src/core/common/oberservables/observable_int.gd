class_name ObservableInt
extends Observable

func _init(initial: int = 0) -> void:
	_value = initial

func set_next(new_value: int) -> void:
	super.set_next(new_value)