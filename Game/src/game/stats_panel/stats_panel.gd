extends Control

@onready var stat_list: VBoxContainer

func _on_game_ready(service: GameService) -> void:
	var stats_info: = DataService.stat_info

	for info in stats_info:
		if info.hidden:
			continue

		var label = Label.new()
		label.text = info.name
		stat_list.add_child(label)