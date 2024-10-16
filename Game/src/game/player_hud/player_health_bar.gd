extends ProgressBar

@onready var _chp_label: Label = %CurrentHpLabel
@onready var _mhp_label: Label = %MaxHpLabel

	
func _on_game_ready(service: GameService) -> void:
	var player_health: = service.get_player().health
	max_value = player_health.maximum
	value = player_health.current
	player_health.health_changed.connect(_on_health_changed)
	player_health.max_health_changed.connect(_on_max_health_changed)
	_mhp_label.text = str(max_value)
	_chp_label.text = str(value)

func _on_health_changed(health: int) -> void:
	value = health
	_chp_label.text = str(value)

func _on_max_health_changed(health: int , max_health: int) -> void:
	max_value = max_health
	value = health
	_mhp_label.text = str(max_health)
	_chp_label.text = str(health)
