extends PanelContainer

@onready var _lvl_label: Label = %PlayerLevelLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(GameService.get_stats().get_stat(Enums.StatType.LEVEL).value)
	GameService.get_stats().get_stat(Enums.StatType.LEVEL).bind(_lvl_label, &"text", true)
 
