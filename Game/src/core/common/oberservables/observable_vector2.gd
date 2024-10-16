class_name ObservableVector2
extends Observable

func _init(initial: Vector2 = Vector2.ZERO):
	_value = initial

func set_next(next: Vector2) -> void:
	if _value.is_equal_approx(next):
		return
	super.set_next(next)