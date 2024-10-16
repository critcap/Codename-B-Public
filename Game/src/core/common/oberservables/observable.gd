class_name Observable
extends RefCounted

## signal emitted when the value is changing, the new value and the sender are passed as arguments
## Use bind method for simple property binding
signal value_changing(value, sender)

## signal emitted when the value has changed, the new value and the sender are passed as arguments
## Use bind method for simple property binding
signal value_changed(value, sender)

var _on_next: Array = []
var _is_changing: bool = false
var _is_canceled: bool = false
var _value = 0
var value : 
	get:
		return _value
		

func _init(start_value):
	_value = start_value

## set the value of the observable 
func set_next(new_value) -> void:
	if _value != new_value:
		_on_next.append(new_value)
		if !_is_changing:
			_process_on_next()

## Creates a one way binding
func bind(target: Object, target_property: String, sync: bool = false) -> Binding:
	var callable = Callable(func(x: float, arg): target.set(target_property, x))
	value_changed.connect(callable)
	if sync:
		target.set(target_property, _value)
	return Binding.new(self, callable)


## cancel current 
func cancel_current() -> void:
	if _is_changing && !_on_next.is_empty() && !_is_canceled:
		_is_canceled = true

## cancel current and all pending changes
func cancel_all() -> void:
	if _is_changing && !_on_next.is_empty():
		_on_next.clear()
		_is_canceled = true

## processing all value changes one after another
func _process_on_next() -> void:
	if _on_next.is_empty() || _is_changing || _is_canceled:
		return
	
	_is_changing = true
	_is_canceled = false
	while !_on_next.is_empty():
		var next = _on_next.pop_front()
		value_changing.emit(next, self)
		if _is_canceled:
			_is_canceled = false
			continue
		_value = next
		value_changed.emit(_value, self)
	_is_canceled = false
	_is_changing = false
