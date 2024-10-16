extends Control

@export var entry_scene: PackedScene
@onready var stat_list: VBoxContainer = %Body

func _ready() -> void:
	var stats_infos: = DataService.stat_info
	for info in stats_infos:

		if !info ||info.hidden:
			continue

		var entry := entry_scene.instantiate() as StatPanelEntry
		stat_list.add_child(entry)
		
		if GameService.get_stats():
			var stat: GameStats.Stat = GameService.get_stats().get_stat(info.id)
			entry.setup(info, stat.value)
			stat.value_changed.connect(entry.set_value)
		else:
			entry.setup(info, 0)
