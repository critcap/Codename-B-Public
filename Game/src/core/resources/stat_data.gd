class_name StatData
extends Resource

## id of the stat
@export var _id: Enums.StatType
var id: Enums.StatType:
	get:
		return _id

## name of the stat
@export var _name: StringName = &""
var name: StringName:
	get:
		return _name

## short name of the stat
@export var _short_name: StringName = &""
var short_name: StringName:
	get:
		return _short_name

## description of the stat
@export var _description: String = ""
var description: String:
	get:
		return _description

## hides this stat in stat panels
@export var _hidden: bool = false
var hidden: bool:
	get:
		return _hidden

## if true, the stat is considered good if it is negative
@export var _negativ_is_good: bool = false
var negativ_is_good: bool:
	get:
		return _negativ_is_good

@export var _value_cap: float = -1
var value_cap: float:
	get:
		return _value_cap

@export var _icon: Texture
var icon: Texture:
	get:
		return _icon
