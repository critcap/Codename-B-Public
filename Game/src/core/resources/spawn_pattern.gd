@icon("res://src/core/shared/puzzle.svg")
class_name SpawnPattern
extends Resource
# spawn patterns are used to define the positions of the enemies in a single spawn action



## Offsets are vectors relative to your spawn point. 
## Use "get_offsets" to get the correct amount depending on your "count"
@export var offsets: Array[Vector2]
## Maximum radius for offsets
@export var radius: Enums.Size
## pick random offsets with "get_offsets" (Still gets cached)
@export var random_offset: bool = false
## If true, the offsets will be used as absolute positions and will not be relative to a spawn point 
@export var is_absolute_position: bool = false