extends Node2D

@export var projectile: PackedScene
@export var projectile_regeneration: float
@export var data: WeaponData
@export var permantent_projectiles: bool = false

@onready var pivot: Node2D = %Pivot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var size: int = data.count;
	var radius: float = data.attack_range;
	for index in range(data.count):
		var child = projectile.instantiate();
		pivot.add_child(child);
		child.set_data(data);
		child.set_physics_process(false);
		var angle = 2 * PI * index / size;
		angle += PI * ( 1.25 if size == 4 else 1.0);
		child.position = Vector2(radius * cos(angle), radius * sin(angle));

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotation += TAU * delta;
