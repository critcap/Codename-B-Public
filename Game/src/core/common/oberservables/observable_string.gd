class_name ObservableString
extends Observable

func _init(initial: String = "") -> void:
	_value = initial
	
func set_next(new_value: String) -> void:
	super.set_next(new_value)
