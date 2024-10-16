class_name WeaponItemData
extends ItemData

var weapon: int
var level: int

func _init(_weapon: WeaponData, level: int, count: int = 1) -> void:
	id = get_instance_id() + count
	name = _weapon.name
	full_name = _weapon.full_name + " Lvl." + str(_weapon.level)
	description = _weapon.description
	rarity = Enums.Rarity.values()[level - 1]
	icon = _weapon.icon
	modifiers = []
	weapon = _weapon.id
	assert(self.weapon)
	level = level
