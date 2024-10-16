extends Node

var _unresolved_notifications: Dictionary = {}


## This function is used to subscribe to a signal that is unique to the object that is emitting it.
func subscribe(signal_name: StringName, handler: Callable) -> void:
	if has_user_signal(signal_name):
		connect(signal_name, handler)
		return

	if _unresolved_notifications.has(signal_name):
		_unresolved_notifications[signal_name].append(handler)
		return
	_unresolved_notifications[signal_name] = [handler]


## This function is used to unsubscribe from a signal
func unsubscribe(signal_name: StringName, handler: Callable) -> void:
	if has_user_signal(signal_name):
		disconnect(signal_name, handler)
		return

	if _unresolved_notifications.has(signal_name):
		_unresolved_notifications[signal_name].erase(handler)
		return


func notify(signal_name: StringName, args: Array = []) -> void:
	if has_user_signal(signal_name):
		callv("emit_signal", [signal_name] + args)
		return

	var index: int = 0
	var new_args: Array = []
	if !args.is_empty():
		for arg in args:
			var new_arg: Dictionary = {}
			new_arg["name"] = str("arg", index)
			new_arg["type"] = typeof(arg)
			assert(new_arg["type"] > 0)
			new_args.append(new_arg)
			index += 1

	add_user_signal(signal_name, new_args)
	assert(has_user_signal(signal_name))
	if _unresolved_notifications.has(signal_name):
		for sub in _unresolved_notifications[signal_name]:
			if sub.is_valid():
				connect(signal_name, sub)
		_unresolved_notifications.erase(signal_name)

	callv("emit_signal", [signal_name] + args)


## This function is used to notify a signal that is unique to the object that is emitting it.
## If notify_base is true, it will also notify the signal_name on the object itself.
func notify_uniquely(
	signal_name: StringName, object: Object, args: Array = [], notify_base: bool = false
) -> void:
	notify(get_unique_signal(signal_name, object), args)
	if notify_base:
		notify(signal_name, args)


## This function is used to obtain a unique signal name for an object.
static func get_unique_signal(signal_name: StringName, object: Object) -> StringName:
	return StringName(str(signal_name) + str(object.get_instance_id()))  ##
