class_name InventoryGrid
extends Control
# * Inventory window inside the pause menu

@export var entry: PackedScene

var _register: Dictionary = {}
var _weapon_index: int = 0

@onready var grid: GridContainer = %GridContainer


func _ready() -> void:
	for item in GameService.get_game().inventory.get_entire_inventory():
		_on_inventory_item_added(item)
	Notifications.subscribe(GameInventory.ITEM_ADDED_NOTIFICATION, _on_inventory_item_added)
	Notifications.subscribe(GameInventory.ITEM_REMOVED_NOTIFICATION, _on_inventory_item_removed)


func _on_inventory_item_added(item: GameInventory.InventoryWrapper) -> void:
	if item.type == Enums.ItemType.WEAPON:
		var entry: = entry.instantiate() as InventoryGridItem
		grid.add_child(entry)
		grid.move_child(entry, _weapon_index)
		entry.refresh(item)
		_weapon_index += 1
		return

	elif item.type != Enums.ItemType.ITEM:
		return

	if _register.has(item.data):
		return
	var entry: = entry.instantiate() as InventoryGridItem
	_register[item.data] = entry
	grid.add_child(entry)
	entry.refresh(item)

func _on_inventory_item_removed(item: GameInventory.InventoryWrapper) -> void:
	if item.type == Enums.ItemType.WEAPON:
		_weapon_index -= 1
		for child in grid.get_children():
			if child.item_data && child.item_data.id == item.data:
				grid.remove_child(child)
				child.queue_free()
				# ! again forgot to break
				break
