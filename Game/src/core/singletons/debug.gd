extends Node

signal message_pushed(message: String)

var backlogs: Array = []
var _is_debug: bool
var _backlog_sent: bool = false

func get_backlogs() -> void:
	if _backlog_sent && backlogs.is_empty():
		return

	for backlog in backlogs:
		message_pushed.emit(backlog)
	backlogs.clear()
	_backlog_sent = true


func print(message: Variant, ignore_debug: bool = false, sender: Node = null) -> void:
	_is_debug = OS.is_debug_build()
	if !_is_debug && ignore_debug:
		return

	var _message: String = str(message) if not message is String else message

	if sender:
		_message = "%1: %2" % [sender.name, _message]
	print(_message)
	if _is_debug:
		if message_pushed.get_connections().is_empty():
			backlogs.append(_message)
		else:
			if !_backlog_sent:
				get_backlogs()
		message_pushed.emit(_message)