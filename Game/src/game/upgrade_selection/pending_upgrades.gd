extends MarginContainer

@export var _upgrade_system: UpgradeSystem
@onready var _upgrade_counter_label: Label = %UpgradesCount#

func _ready() -> void:
	_upgrade_system.remaining_level_ups.value_changed.connect(_on_remaining_upgrades_changed)
	
func _on_remaining_upgrades_changed(level_ups: int, _observable) -> void:
	if level_ups <= 0:
		hide()
		return
	_upgrade_counter_label.text = str(level_ups)
	show()
