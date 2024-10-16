extends ProgressBar


func _ready() -> void:
	max_value = GameSettings.calculate_required_experience(1)
	value = 0
	Notifications.subscribe(PlayerExperience.LEVEL_UP_NOTIFICATION, _on_level_up)
	Notifications.subscribe(PlayerExperience.EXP_GAINED_NOTIFICATION, _on_experience_gained)

func _on_level_up(level: int, exp: int) -> void:
	max_value = GameSettings.calculate_required_experience(level)
	value = exp

func _on_experience_gained(amount: int) -> void:
	value = amount

