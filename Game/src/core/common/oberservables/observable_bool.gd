class_name ObservableBool
extends Observable

func _init(initial: bool = false) -> void:
	_value = initial
	
func set_next(new_value: bool) -> void:
	super.set_next(new_value)
