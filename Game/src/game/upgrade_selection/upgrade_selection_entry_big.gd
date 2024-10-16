class_name UpgradeSelectionEntryBig
extends PanelContainer

@export var index: int = 1
@export var keybind: TextureRect

@onready var button: Button = %Button
@onready var _icon: TextureRect = %Icon
@onready var _label_name: Label = %Name
@onready var _label_rarity: Label = %Rarity
@onready var _textbox_discription: Label = %Description
@onready var _list_mods: VBoxContainer = %ModList

func _ready() -> void:
	keybind = %KeybindRect as TextureRect
	var atlas: AtlasTexture = keybind.texture as AtlasTexture
	atlas.region.position.x += 17 * (index - 1)

func refresh(item_data: UpgradeSystem.UpgradeItemWrapper) -> void:
	_icon.texture = item_data.icon
	_label_name.text = item_data.full_name
	_label_rarity.text = ItemData.get_rarity_string(item_data.rarity)
	_textbox_discription.text = item_data.get_description()
	
	var m_size: int = item_data.modifiers.size()
	for i in range(4):
		if i < m_size:
			_list_mods.get_children()[i].show()
			_list_mods.get_children()[i].refresh(item_data.modifiers[i])
		else:
			_list_mods.get_children()[i].hide()
	
	
