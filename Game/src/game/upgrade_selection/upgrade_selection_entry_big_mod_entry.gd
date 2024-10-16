extends HBoxContainer

@onready var _label_value: Label = %Value
@onready var _label_stat: Label = %Stat

func refresh(data: ModifierData) -> void:
	_label_value.text = data.get_value_string()
	_label_stat.text = DataService.get_stat_by_id(data.type).name
