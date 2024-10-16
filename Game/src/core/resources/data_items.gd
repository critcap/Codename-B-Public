class_name ItemData
extends Resource

@export var id := 0
@export var name: StringName
@export var full_name := ""
@export var description := ""
@export var rarity : Enums.Rarity = Enums.Rarity.COMMON
@export var price := 0
@export var max_count := 0
@export var icon : Texture
@export var modifiers: Array[ModifierData]

static func get_rarity_string(_rarity: Enums.Rarity) -> String:
	return str(Enums.Rarity.keys()[_rarity]).capitalize()
	
func get_description() -> String:
	var _description: String = description
	if modifiers.is_empty():
		return description
	return _description.format({"val": modifiers[0].value})
