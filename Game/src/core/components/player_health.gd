class_name PlayerHealth
extends Health

signal max_health_changed(current: int, maximum: int)

@onready var _chp_stat := GameService.get_stats().get_stat(Enums.StatType.HEALTH)
@onready var _mhp_stat := GameService.get_stats().get_stat(Enums.StatType.MAX_HEALTH)


func _ready():
	current = maximum
	_chp_stat.value_changed.connect(func(x: float): 
		current = x
		health_changed.emit(current))
	_mhp_stat.value_changed.connect(func(x: float): 
		maximum = x
		max_health_changed.emit(current, maximum))
	maximum = _mhp_stat.value
	current = maximum	
	_chp_stat.set_base(current)


func set_current(value: int):
	_chp_stat.set_base(mini(maximum,value))

## ! only use on start
func set_maximum(value: int):
	var difference = value - maximum
	_mhp_stat.set_base(value)
