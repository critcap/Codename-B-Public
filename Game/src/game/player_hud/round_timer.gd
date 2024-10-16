extends Control

@onready var _label: Label = %Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var time_left = GameService.get_timer().wait_time - GameService.get_timer().time_left
	var minutes: String = str(int(time_left/60)).lpad(2,"0")
	var seconds: String = str(int(time_left)%60).lpad(2,"0")
	_label.text = minutes + ":" + seconds 
