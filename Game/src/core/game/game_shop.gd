class_name GameShop
extends RefCounted

const WEAPON_PROPABILITY := 0.4

var _available_items: Dictionary = {}
var _base_weapons: Array[WeaponData] = []
var _weapon_upgrades: Dictionary = {}


func _init(
	items: Array[ItemData], weapons: Array[WeaponData], start_weapons: Array[WeaponData] = []
):
	# add start weapons as base
	_base_weapons = start_weapons

	for item in items:
		var rarity := _available_items.get_or_add(item.rarity, []) as Array
		rarity.append(item)

	for weapon in weapons:
		if weapon.price > 0:
			continue
		if weapon.level > 1:
			# can add weapon upgrades from locked weapons because you need the base weapon to upgrade
			_weapon_upgrades[str(weapon.name, weapon.level)] = weapon
			continue
		_base_weapons.append(weapon)


func get_rarity_roll(roll: float, wave: int, luck: float) -> Enums.Rarity:
	if roll <= clampf((0.02 * (wave - 3) + 0.0) * (1 + luck * 0.01), 0.0, 0.25):
		return Enums.Rarity.EPIC
	if roll <= clampf((0.06 * (wave - 1) + 0.0) * (1 + luck * 0.01), 0.0, 0.40):
		return Enums.Rarity.RARE
	return Enums.Rarity.COMMON


func get_upgrade_selection(
	required_slots: Array[Enums.PrizeType], inventory: GameInventory, wave: int, luck: float
) -> Array:
	# upgrade selection
	var upgrades: Dictionary = {}

	var upgradeable_weapons := inventory.get_weapons().filter(
		func(x: WeaponData) -> bool: return (x.level - 1) < Enums.Rarity.LEGENDARY
	)
	# upgradeable weapons sorted by level
	upgradeable_weapons.sort_custom(
		func(a: WeaponData, b: WeaponData) -> bool: return a.level < b.level
	)
	# do we have stuff to upgrade?
	inventory.has_upgradeables = !upgradeable_weapons.is_empty()

	# null values get replaced by random rolls
	required_slots.resize(GameSettings.DEFAULT_UPGRADE_COUNT)

	var rarity: Enums.Rarity
	var type_roll: float = randf()
	while upgrades.size() < GameSettings.DEFAULT_UPGRADE_COUNT:
		var slot = required_slots[upgrades.size()]
		type_roll = randf()
		rarity = get_rarity_roll(randf(), wave, luck)
		# if we have a null slot, we need to decide what to put in there
		if slot == 0:
			slot = (
				Enums.PrizeType.WEAPON_UPGRADE
				if type_roll < WEAPON_PROPABILITY && rarity > Enums.Rarity.COMMON
				else (
					Enums.PrizeType.WEAPON_BASE
					if type_roll < WEAPON_PROPABILITY
					else Enums.rarity_to_prize(rarity)
				)
			)
			required_slots[upgrades.size()] = slot
		if slot == Enums.PrizeType.WEAPON_UPGRADE:
			# handle upgrades
			if !upgradeable_weapons.is_empty():
				var upgradable: WeaponData = upgradeable_weapons.pop_front()
				# * can only upgrade if rarity roll is higher than current weapon
				if upgradable.level <= int(rarity):
					var key: String = str(
						upgradable.name,
						# * +1 offset because rarity starts at 0 and weapon level at 1
						min(rarity + 1, Enums.Rarity.LEGENDARY + 1)
					)

					if _weapon_upgrades.has(key):
						upgrades[key] = _weapon_upgrades.get(key)
						continue
			# if we cannot upgrade, we need to roll again and change slot to something else
			slot = Enums.PrizeType.WEAPON_BASE
		elif slot == Enums.PrizeType.WEAPON_BASE:
			if inventory.weapon_count < GameSettings.MAX_WEAPONS:
				# this should only be called if we have less than 3 weapons in your DB
				assert(upgrades.values().size() < _base_weapons.size(), "Not enough base weapons")
				var random_weapon: WeaponData = _base_weapons.pick_random()
				if upgrades.has(random_weapon.name):
					continue
				upgrades[random_weapon.name] = random_weapon
				continue
			# save the rarity for next cycle
			slot = Enums.rarity_to_prize(rarity)
		# restore previous rarity from last cycle
		rarity = Enums.prize_to_rarity(slot)
		# lower rarity if there are no items of that rarity left
		if _available_items.has(rarity):
			var item: ItemData = _available_items.get(rarity).pick_random()
			if !upgrades.has(item.name):
				upgrades[item.name] = item
			if _available_items.get(rarity).size() > 1:
				continue
		# if we cannot find an item of the desired rarity, we need to roll again
		if rarity - 1 < Enums.Rarity.COMMON:
			# should not happen
			assert(false)
		required_slots[upgrades.size()] = Enums.rarity_to_prize(rarity - 1)

	# change items to array
	var upgrades_selection = upgrades.values()
	assert(upgrades_selection)
	if inventory.weapon_count >= GameSettings.MAX_WEAPONS:
		for upgrade in upgrades_selection:
			if upgrade is WeaponData && upgrade.level == 1:
				assert(false)
	assert(upgrades_selection.size() == GameSettings.DEFAULT_UPGRADE_COUNT)
	assert(!upgrades_selection.has(null))
	return upgrades_selection
