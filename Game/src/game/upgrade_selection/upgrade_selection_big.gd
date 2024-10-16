extends Control

@export var upgrade_system: UpgradeSystem
@export var _hide_timer: float = 0.5
@export var _fast_forward_factor: float = 4.0

var _entries: Array[UpgradeSelectionEntryBig]
var _tween: Tween

# Displayed when upgrades are available
@onready var upgrade_container: Control = %UpgradeContainer
# Displayed when no upgrades are available
@onready var empty_container: Control = %EmptyContainer

func _ready() -> void:
	if !upgrade_system:
		printerr("UpgradeSelection: upgrade_system is not set")
		return
	upgrade_system.upgrades_changed.connect(_on_upgrades_changed)


	set_process_unhandled_key_input(false)
	_entries = [%Entry1,%Entry2,%Entry3]	
	for entry in _entries:
		entry.button.pressed.connect(func() -> void:
			_on_upgrade_selected(_entries.find(entry))
			)
			
	upgrade_container.draw.connect(func() -> void:
		empty_container.visible = false
		set_process_unhandled_key_input(true)
		)

	upgrade_container.hidden.connect(func() -> void:
		empty_container.visible = true
		set_process_unhandled_key_input(false)
		)
		
	Notifications.subscribe(UpgradeSystem.UPGRADED_SELECTED_NOTIFICATION, func(arg) -> void:
		if _tween && _tween.is_running():
			return
		upgrade_container.hide()
		)


func _unhandled_key_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed(&"upgrade_select_1"):
			_on_upgrade_selected(0)
		elif event.is_action_pressed(&"upgrade_select_2"):
			_on_upgrade_selected(1)
		elif event.is_action_pressed(&"upgrade_select_3"):
			_on_upgrade_selected(2)


func _on_upgrade_selected(index: int) -> void:
	set_process_unhandled_key_input(false)
	get_viewport().set_input_as_handled()
	_tween = create_tween()
	# hide faster if there a remaining upgrades
	var tween_speed = _hide_timer / _fast_forward_factor if upgrade_system.remaining_level_ups.value > 0 else _hide_timer
	_entries[index].button.toggle_mode = false
	_entries[index].button.button_pressed = false
	set_process_unhandled_key_input(false)
	_tween.tween_property(upgrade_container, "modulate:a", 0.2, tween_speed)
	_tween.tween_callback(func() -> void: upgrade_container.hide())
	upgrade_system.select_upgrade(index)


func _on_upgrades_changed(upgrades: Array[UpgradeSystem.UpgradeItemWrapper]) -> void:
	if upgrades.size() < 3:
		printerr("UpgradeSelection: not enough upgrades")
		return

	if _tween && _tween.is_running():
		# * wait for tween
		await _tween.finished
	
	for index in range(3):
		_entries[index].refresh(upgrades[index])
	upgrade_container.modulate.a = 1.0
	upgrade_container.visible = true
	if GameService.get_context().is_game_paused.value:
		set_process_unhandled_key_input(true)
