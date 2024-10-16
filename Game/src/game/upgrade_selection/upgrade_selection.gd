extends Control

@export var upgrade_system: UpgradeSystem
@export var _hide_timer: float = 0.5
@export var _fast_forward_factor: float = 4.0

var _entries: Array[UpgradeSelectionEntry]
var _tween: Tween

#@onready var upgrade_label: Label = %Upgrades

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
			
	#upgrade_system.remaining_level_ups.value_changed.connect(func(value: int, _sender) -> void:
		#if value == 0:
			#upgrade_label.hide()
		#else:
			#upgrade_label.show()
			#upgrade_label.text = str(value)
		#)
	
	self.draw.connect(func() -> void:
		set_process_unhandled_key_input(true)
		)

	self.hidden.connect(func() -> void:
		set_process_unhandled_key_input(false)
		)

	Notifications.subscribe(UpgradeSystem.UPGRADED_SELECTED_NOTIFICATION, func(arg) -> void:
		if is_instance_valid(_tween) && _tween.is_running():
			return
		hide()
		set_process_unhandled_key_input(false)
		)
	Notifications.subscribe(VictorySystem.GAMEOVER_NOTIFICATION, func(arg): 
		hide()
		set_process_unhandled_key_input(false)
		)
	

func _unhandled_key_input(event: InputEvent) -> void:
	if GameService.get_context().is_game_paused.value or !visible:
		return
		
	if event.is_action_pressed(&"upgrade_select_1"):
		_on_upgrade_selected(0)
	elif event.is_action_pressed(&"upgrade_select_2"):
		_on_upgrade_selected(1)
	elif event.is_action_pressed(&"upgrade_select_3"):
		_on_upgrade_selected(2)


func _on_upgrade_selected(index: int) -> void:
	get_viewport().set_input_as_handled()
	set_process_unhandled_key_input(false)
	_tween = create_tween()
	# hide faster if there a remaining upgrades
	var tween_speed = _hide_timer / _fast_forward_factor if upgrade_system.remaining_level_ups.value > 0 else _hide_timer
	_entries[index].button.toggle_mode = false
	_entries[index].button.button_pressed = false
	_tween.tween_property(self, "modulate:a", 0.0, tween_speed)
	_tween.tween_callback(func() -> void:
		self.visible = false
		)
	_tween.play()
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

	# reset visibility
	modulate.a = 1.0
	visible = true
