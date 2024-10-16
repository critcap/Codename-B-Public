class_name WeaponData
extends Resource

enum Pattern {CONE, RANDOM, CIRCLE}
enum Deviation {NONE, LOW, MID, HIGH}

const NO_DEVIATION: = 0.0
const LOW_DEVIATION: = 0.0174533
const MID_DEVIATION: = 0.026179955
const HIGH_DEVIATION: = 0.0349066

## mostly for the shop item export
@export_category("Misc")
@export var id := 0
@export var name := ""
@export var full_name := ""
@export var description := ""
@export var price := 0
@export var icon : AtlasTexture
@export var level := 0
@export var max_count := 1

@export_category("Weapon Data")
@export var damage := 0
## how many targets are shot per sequence
@export var targets := 0
## target range of weapon and travel range of bullets
@export var attack_range := 0
## how often the weapon can fire a sequence
@export var attack_speed := 0.0
## how often the weapon repeats one sequence before it goes on cooldown
@export var repeat := 0
## time between each bullet in a sequence
@export var delay := 0.0
## how many bullets are emitted per sequence 
@export var count := 0
@export var pattern : Pattern= Pattern.CONE
@export var _deviation: Deviation = Deviation.NONE
## This scene replaces the weapon.gd based scene with an alternative one
@export var scene : Resource

@export_category("Projectile Data")
@export var projectile_speed := 0
@export var size_multiplier := 1.0
@export var bounces := 0
@export var pierce := 0
@export var terrain_bounce := false
@export var return_to_player := false
@export var allow_shotgunning: bool = false
@export var is_random_dir := false
## secondary projectile scene which can be used for bounce, pierce, terrain_bounce, return
@export var secondary_projectile: Resource

@export_category("Visuals")
@export var is_rotating: bool = false :
	set(value):
		if value:
			is_fixed = true
		is_rotating = value
@export var rotation_speed: float = 1
@export var is_fixed := false : 
	set(value):
		if !value && is_rotating:
			is_rotating = false
		is_fixed = value
# TODO sprite and hitbox scale should be dependend on the chosen animation and should be handled on the bullet
@export_enum("default", "ice", "spark", "bat", "tornado", "portal", "sword", "dagger") var animations: String = "default"
@export var sprite_scale: float = 1.0
@export var hitbox_scale: float = 1.0

@export var desaturate: bool = false
@export var color: Color = Color(1, 1, 1, 1)

var deviation: float  :
	get:
		if _deviation == Deviation.LOW:
			return LOW_DEVIATION
		if _deviation == Deviation.MID:
			return MID_DEVIATION
		if _deviation == Deviation.HIGH:
			return HIGH_DEVIATION
		return NO_DEVIATION

var can_bounce: bool :
	get:
		return bounces > 0

var can_pierce: bool :
	get:
		return pierce > 0
