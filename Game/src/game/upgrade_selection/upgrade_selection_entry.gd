class_name UpgradeSelectionEntry
extends Control

@export var index: int

@onready var button: = %Button as Button
@onready var _label: = %Name as Label
@onready var _primary: = %Primary as Label




func _ready() -> void:
	var keybind = %KeybindRect as TextureRect
	var atlas: AtlasTexture = keybind.texture as AtlasTexture
	atlas.region.position.x += 17 * (index - 1)

	button.pressed.connect(func() -> void:
		button.toggle_mode = true
		button.button_pressed = true
		)

func refresh(data: UpgradeSystem.UpgradeItemWrapper) -> void:
	_label.text = data.short_description
	# if data.modifiers.size() > 0 && data.modifiers[0] != null:
	# 	var mod: ModifierData = data.modifiers[0]
	# 	_primary.text = mod.get_value_string()+ " " + DataService.get_stat_by_id(mod.type).name
	# else:
	_primary.text = ""
	button.icon = data.icon
	button.toggle_mode = false
	button.button_pressed = false
