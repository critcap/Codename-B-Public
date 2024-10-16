class_name InventoryGridItem 
extends Control

@onready var _icon: TextureRect = %Icon
@onready var _count: Label = %LabelCount

var item_data: WeaponData

func refresh(item: GameInventory.InventoryWrapper) -> void:
	if item.type == Enums.ItemType.WEAPON:
		item_data = DataService.get_weapon_by_id(item.data)
		assert(item_data)
	var data = DataService.get_weapon_by_id(item.data) if item.type == Enums.ItemType.WEAPON else DataService.get_item_by_id(item.data)
	_icon.texture = data.icon
	_icon.show()
	item.count.bind(_count, &"text", true)

	# build tooltip
	var tooltip: String = data.full_name + "\n"
	tooltip += (data.get_description() if data.has_method(&"get_description") else data.description) + "\n"
	if item.type == Enums.ItemType.ITEM:
		for mods in data.modifiers:
			tooltip += mods.get_value_string() + " " + DataService.get_stat_by_id(mods.type).name + "\n"
	tooltip += "ID: " + str(data.id) + "\n"
	tooltip_text = tooltip
