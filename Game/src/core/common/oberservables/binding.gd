class_name Binding
extends RefCounted

var _callable: Callable
var _holder: WeakRef


func _init(holder: Object, callable: Callable) -> void:
	_holder = weakref(holder)
	_callable = callable


func is_valid() -> bool:
	return _callable.is_valid() && _holder.get_ref() != null


func release() -> void:
	if !is_valid():
		return
	var holder = _holder.get_ref()
	if holder.has_signal(&"value_changed"):
		holder.value_changed.disconnect(_callable)


func free() -> void:
	release()
	_holder = null
