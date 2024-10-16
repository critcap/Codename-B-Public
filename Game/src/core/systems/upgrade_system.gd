class_name UpgradeSystem
extends Node

## Signal emitted when the upgrades are changed. (upgrades: Array[UpgradeItemWrapper])
signal upgrades_changed(upgrades: Array[UpgradeItemWrapper])
## Signal emitted when an upgrade is selected. (upgrade: UpgradeItemWrapper)
const UPGRADED_SELECTED_NOTIFICATION: StringName = &"f38b2ba3-6f57-4439-b7c4-36d98ea6ad02"

@export var upgrade_selected_audio_player: AudioStreamPlayer

## Remaining level ups to select
var remaining_level_ups: ObservableInt = ObservableInt.new(0)
## Current upgrades available for selection
var upgrades: Array[UpgradeItemWrapper] = []
## Saved waves for level up. Processed on level up and when there is no stored prize waves
var _levelup_waves: Array = []
## Saved rewards for prizes e.g. on wave end. Processed before the next level up selection
## Keys: wave: int, required_upgrades: Array[GameShop.UpgradeSlots], luck: float
var _prize_waves: Array[Dictionary] = []

@onready var luck_stat := GameService.get_stats().get_stat(Enums.StatType.LUCK)
@onready var _shop: GameShop = GameService.get_game().shop
@onready var _inventory: GameInventory = GameService.get_game().inventory


func _ready() -> void:
	set_process_unhandled_key_input(OS.is_debug_build())
	Notifications.subscribe(PlayerExperience.LEVEL_UP_NOTIFICATION, _on_level_up)


## Adds a prize selection to the prize waves.
## If there are no remaining level ups, the prize is processed immediately.
## If there are remaining level ups, the prize is processed after the current level up selection.
func add_prize_selection(wave: int, required_upgrades: Array[Enums.PrizeType]) -> void:
	assert(!required_upgrades.is_empty(), "Prizes must have required upgrades")
	if remaining_level_ups.value > 0 || !upgrades.is_empty():
		_prize_waves.append(
			{"wave": wave, "required_upgrades": required_upgrades, "luck": luck_stat.value}
		)
		return
	upgrades = _get_upgrades(wave, required_upgrades, luck_stat.value)
	upgrades_changed.emit(upgrades)


## Selects an upgrade from the current available upgrades.
func select_upgrade(index: int) -> void:
	assert(upgrades || !upgrades.is_empty(), "No upgrades available")
	assert(upgrades.size() >= index, "Index out of bounds")

	var selected_upgrade := upgrades[index]
	if selected_upgrade.type == Enums.ItemType.WEAPON:
		_inventory.add_weapon(selected_upgrade.item as WeaponData)
	elif selected_upgrade.type == Enums.ItemType.UPGRADE:
		_inventory.upgrade_weapon(selected_upgrade.item as WeaponData)
	elif selected_upgrade.type == Enums.ItemType.ITEM:
		_inventory.add_item(selected_upgrade.item as ItemData)
	else:
		assert(false, "Wrong Upgrade type")

	Notifications.notify(UPGRADED_SELECTED_NOTIFICATION, [upgrades[index]])
	remaining_level_ups.set_next(maxi(remaining_level_ups.value - 1, 0))
	upgrade_selected_audio_player.play()

	upgrades.clear()
	if !_prize_waves.is_empty():
		var prize := _prize_waves.pop_front() as Dictionary
		upgrades = _get_upgrades(prize["wave"], prize["required_upgrades"], prize["luck"])
		upgrades_changed.emit(upgrades)
	elif remaining_level_ups.value > 0:
		var wave = _levelup_waves.pop_front()
		upgrades = _get_upgrades(wave)
		upgrades_changed.emit(upgrades)


func _on_level_up(_level: int, _experience: int) -> void:
	remaining_level_ups.set_next(remaining_level_ups.value + 1)
	var wave = GameService.get_context().current_wave
	if !upgrades.is_empty():
		_levelup_waves.append(wave)
		return
	upgrades = _get_upgrades(wave)
	upgrades_changed.emit(upgrades)


func _get_upgrades(
	wave: int, required_upgrades: Array[Enums.PrizeType] = [], luck_overwrite: float = -1.0
) -> Array[UpgradeItemWrapper]:
	var items := _shop.get_upgrade_selection(
		required_upgrades,
		_inventory,
		wave,
		luck_stat.value if luck_overwrite < 0.0 else luck_overwrite
	)
	var fuck_typed_array: Array[UpgradeItemWrapper] = []
	fuck_typed_array.append_array(
		items.map(func(item) -> UpgradeItemWrapper:
			# to display the count of items in the upgrade selection inside the game
			var count: int = _inventory.get_item_count(item) + 1 if item is ItemData else 0
			return UpgradeItemWrapper.new(item, count))
	)
	return fuck_typed_array


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("magickey_force_upgrade"):
		add_prize_selection(1, [Enums.PrizeType.WEAPON_UPGRADE])


class UpgradeItemWrapper:
	extends RefCounted

	const WEAPON_FULL_NAME: String = "%s Lvl.%d"
	const ITEM_FULL_NAME: String = "%s +%d"

	## Wrapped Resource. Is either WeaponData or ItemData. To check use the type property
	var item

	var id: int
	var type: Enums.ItemType 
	var rarity: Enums.Rarity = Enums.Rarity.COMMON
	var icon: Texture
	var short_description: String = ""
	var full_name: String = ""
	var description: String = ""
	var modifiers: Array[ModifierData]

	func _init(_item, count: int = 0) -> void:
		item = _item
		assert(item)
		id = _item.id
		type = Enums.ItemType.WEAPON if _item is WeaponData else Enums.ItemType.ITEM
		icon = _item.icon
		full_name = _item.full_name
		description = _item.description
		if type == Enums.ItemType.ITEM:
			short_description = ITEM_FULL_NAME % [_item.full_name, count]
			rarity = _item.rarity
			modifiers = _item.modifiers
		if type == Enums.ItemType.WEAPON: 
			rarity = Enums.Rarity.values()[_item.level - 1]
			short_description = WEAPON_FULL_NAME % [_item.full_name, _item.level]
			if _item.level > 1:
				type = Enums.ItemType.UPGRADE

	func get_description() -> String:
		if type == Enums.ItemType.WEAPON:
			return description
		if modifiers.is_empty():
			return description
		return description.format({"val": modifiers[0].value})
