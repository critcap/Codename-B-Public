class_name GameInventory
extends Object

## Notification sent when an item is added to the inventory (InventoryWrapper)
const ITEM_ADDED_NOTIFICATION: StringName = &"31f51f09-b63d-4adc-872b-26f56929d905"
## Notification sent when an item is removed from the inventory (InventoryWrapper)
const ITEM_REMOVED_NOTIFICATION: StringName = &"a6e526b2-b4d9-4cfb-96a5-2866de4fde3d"
## Notification sent when an item (weapon) is upgraded (old: InventoryWrapper, new: InventoryWrapper)
const ITEM_UPGRADED_NOTIFICATION: StringName = &"1cbc7f7f-a4aa-4144-80e3-e3fedd90cf8e"


## Whether the inventory has upgradeable items
var has_upgradeables: bool = true
var weapon_count: int :
	get:
		return _weapons.size()

var _weapons := []
var _inventory := {}

#region Weapons

## Adds an weapon to the inventory
func add_weapon(weapon: WeaponData) -> void:
	if _weapons.size() >= GameSettings.MAX_WEAPONS:
		assert(false, "The inventory is full")
		return
	var wrapper := InventoryWrapper.new(weapon, Enums.ItemType.WEAPON, 1)
	_weapons.append(wrapper)
	Notifications.notify(ITEM_ADDED_NOTIFICATION, [wrapper])

func upgrade_weapon(upgrade: WeaponData) -> void:
	var upgradeables: = get_weapons().filter(func(weapon: WeaponData) -> bool:
		return weapon.name == upgrade.name && weapon.level < upgrade.level)
	assert(!upgradeables.is_empty())
	# take lowest weapon to upgrade. Gönn digga, gönn!
	if upgradeables.size() > 1:
		upgradeables.sort_custom(func(a: WeaponData, b: WeaponData) -> int:
			return a.level < b.level
		)
	var weapon_new := InventoryWrapper.new(upgrade, Enums.ItemType.WEAPON, 1)
	var weapon_old: InventoryWrapper
	for wrapper in _weapons:
		if wrapper.data == upgradeables[0].id:
			weapon_old = wrapper
			# need to notify removal to clear item from the inventory
			Notifications.notify(ITEM_REMOVED_NOTIFICATION, [wrapper])
			_weapons.erase(wrapper)
			# ! break here or it will overwrite all similar weapons
			break
			
	assert(weapon_old)
	_weapons.append(weapon_new)
	Notifications.notify(ITEM_ADDED_NOTIFICATION, [weapon_new])
	Notifications.notify(ITEM_UPGRADED_NOTIFICATION, [weapon_old, weapon_new])
	
	
## Checks if an instance of the given weapon is in the inventory
func has_weapon(weapon: WeaponData) -> bool:
	for item in _weapons:
		if item.data == weapon.id:
			return true
	return false

## Removes an weapon from the inventory
func remove_weapon(weapon: WeaponData) -> void:
	for wrapper in _weapons:
		if wrapper.data == weapon.id:
			Notifications.notify(ITEM_REMOVED_NOTIFICATION, [wrapper])
			_weapons.erase(wrapper)


## Replaces the current weapon with the upgrade weapon
## Returns true if the weapon was successfully replaced, false otherwise
func replace_weapon(current: WeaponData, upgrade: WeaponData) -> bool:
	if !has_weapon(current):
		return false
	assert(
		upgrade.level == current.level + 1,
		"The upgrade weapon must be one level higher than the current weapon"
	)
	remove_weapon(current)
	add_weapon(upgrade)
	return true


## Returns an array of your current weapons. Its duplicated and thus changed dont carry over to the inventory
func get_weapons() -> Array:
	return _weapons.map(func(x: InventoryWrapper) -> WeaponData: return DataService.get_weapon_by_id(x.data))

#endregion

#region Items


func add_item(item: ItemData) -> void:
	var wrapper := (
		_inventory.get_or_add(item.name, InventoryWrapper.new(item, Enums.ItemType.ITEM))
		as InventoryWrapper
	)
	wrapper.count.set_next(wrapper.count.value + 1)
	Notifications.notify(ITEM_ADDED_NOTIFICATION, [wrapper])


func get_item_by_name(name: StringName) -> InventoryWrapper:
	if !_inventory.has(name):
		return null
	return _inventory.get(name) as InventoryWrapper


## Returns the number of items of the given type in the inventory
func get_all_items() -> Array[ItemData]:
	var items: Array[ItemData] = []
	for item in _inventory.values():
		items.append(DataService.get_item_by_id(item.data))
	return items

func get_item_count(item: ItemData) -> int:
	var wrapper: InventoryWrapper = _inventory.get(item.name)
	if wrapper:
		return wrapper.count.value
	return 0
		
#endregion


func get_entire_inventory() -> Array[InventoryWrapper]:
	var this_typing_system_sucks: Array[InventoryWrapper] = []
	this_typing_system_sucks.append_array(_weapons)
	this_typing_system_sucks.append_array(_inventory.values())
	return this_typing_system_sucks


## Wrapper for an item in the inventory
class InventoryWrapper:
	extends RefCounted
	var data: int
	var count: ObservableInt
	var type: Enums.ItemType

	func _init(item: Object, type: Enums.ItemType, count: int = 0) -> void:
		self.data = item.id
		self.type = type
		self.count = ObservableInt.new(count)
