class_name Directions

enum {
  NORTH,
  EAST,
  SOUTH,
  WEST,
}


static func from_vector2(vector: Vector2) -> int:
	if vector == Vector2(0, -1):
		return NORTH
	elif vector == Vector2(1, 0):
		return EAST
	elif vector == Vector2(0, 1):
		return SOUTH
	elif vector == Vector2(-1, 0):
		return WEST
	else:
		push_error("Invalid vector")
		return -1

static func to_string_name(direction: int) -> StringName:
	if direction == NORTH:
		return &"north"
	elif direction == EAST:
		return &"east"
	elif direction == SOUTH:
		return &"south"
	elif direction == WEST:
		return &"west"
	else:
		push_error("Invalid direction")
		return &""