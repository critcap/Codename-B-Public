@tool
class_name WeaponRig
extends Node2D
# The WeaponRig is a container for weapons that are attached to the player.
# It is responsible for managing the position of the weapons around the player.

# The radius of the circle that the weapons are positioned on.
@export var radius: int
@export var max_weapons: int



# Called when the node enters the scene tree for the first time.
func _ready():
	Notifications.subscribe(GameInventory.ITEM_UPGRADED_NOTIFICATION, _on_upgrade_added)
	Notifications.subscribe(GameInventory.ITEM_ADDED_NOTIFICATION, _on_weapon_added)


func _on_weapon_added(item: GameInventory.InventoryWrapper) -> void:
	if item.type != Enums.ItemType.WEAPON:
		return
	var weapon: = DataService.get_weapon_by_id(item.data) as WeaponData
	if weapon.level > 1:
		return
	assert(weapon)
	add_weapon_from_data(weapon)


func _on_upgrade_added(old: GameInventory.InventoryWrapper, new:GameInventory.InventoryWrapper) -> void:
	var current: = DataService.get_weapon_by_id(old.data) as WeaponData
	var upgrade: = DataService.get_weapon_by_id(new.data) as WeaponData
	for child in get_children():
		if child.data != current:
			continue
		child.data = upgrade
		return
	#assert(false, "Could not find weapon to upgrade")


func add_weapon_from_data(data: WeaponData) -> void:
	if get_child_count() < GameSettings.MAX_WEAPONS:
		var weapon: Node2D
		if data.scene == null:
			weapon = load("res://src/weapons/GenericRangeWeapon/GenericRangeWeapon.tscn").instantiate() as Weapon
			assert(weapon is Weapon)
		else:
			weapon = data.scene.instantiate()
		weapon.data = data
		assert(weapon.data)
		add_child(weapon)			


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_manual_aim"):
		GameService.get_context().is_manual_aim.set_next(!GameService.get_context().is_manual_aim.value)

# Order the weapons in a circle around the player
#func refresh_weapon_positions(_child: Node) -> void:
	#var children = get_children()
	#var current = children.size()
	## ! Update the current number of weapons
	#var index: int = 0
	#for child in children:
		#var angle = 2 * PI * index / current;
		#angle += PI * ( 1.25 if current == 4 else 1.0);
		#child.position = Vector2(radius * cos(angle), radius * sin(angle));
		#index += 1
