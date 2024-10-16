class_name LobbyLog
extends TextEdit

func _ready():
	if OS.is_debug_build():
		Debug.message_pushed.connect(push_message)
		Debug.call_deferred(&"get_backlogs")
		return
	queue_free()

func push_message(message: String) -> void:
	text += str(Time.get_datetime_string_from_system() + ": " + message + "\n")
	scroll_vertical += 99999
