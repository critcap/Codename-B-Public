extends Control

## Emit signal gameover_processed() when the gameover screen is visible and the player presses the accept button.
signal gameover_processed()

var visible_tween: Tween
@onready var message_label: Label = %Message

func _ready():
	set_process_unhandled_input(false)
	draw.connect(Callable(self, "set_process_unhandled_input").bind(true))
	GameService.get_context().is_gameover.value_changed.connect(_on_gameover)
	GameService.get_context().is_gamewon.value_changed.connect(_on_gamewon)

func _on_gameover(is_gameover: bool, _observable) -> void:
	if is_gameover:
		visible = true
		modulate.a = 0.0
		visible_tween = self.create_tween()
		visible_tween.tween_property(self, "modulate:a", 1.0, GameSettings.gameover_wait_time)

func _on_gamewon(is_gamewon: bool, _observable) -> void:
	if is_gamewon:
		visible = true
		message_label.text = tr("GAMEWON_MESSAGE")
		modulate.a = 0.0
		visible_tween = self.create_tween()
		visible_tween.tween_property(self, "modulate:a", 1.0, GameSettings.gameover_wait_time)

func _unhandled_input(event):
	if visible_tween && visible_tween.is_running() && modulate.a < 1.0:
		if event.is_action_pressed("ui_accept"):
			visible_tween.set_speed_scale(999)
			return
	
	if event.is_action_pressed("ui_accept") && modulate.a >= 1.0:
		gameover_processed.emit()
