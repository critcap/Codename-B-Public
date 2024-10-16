class_name StatPanelEntry 
extends Control

var _is_negative_positive: bool = false

@onready var _stat_name: Label = %StatName
@onready var _value_label: Label = %ValueLabel
@onready var _icon: TextureRect = %Icon


func setup(stat_info: StatData, value: float) -> void:
	tooltip_text = stat_info.description
	_icon.texture = stat_info.icon if stat_info.icon else null
	_value_label.text = str(int(value))
	_stat_name.text = stat_info.name 
	_is_negative_positive = stat_info._negativ_is_good


func set_value(value) -> void:
	if value is float:
		# remove decimal
		value = int(value)
	_value_label.text = str(value)
