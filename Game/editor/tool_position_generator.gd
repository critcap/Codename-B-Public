@tool
extends Node

enum Spread { TIGHT = 30, MEDIUM = 60, NOT_far = 75, FAR = 90 }

@export var map: Map
@export var spread: Spread = Spread.MEDIUM
@export var get_max_points: bool = false
@export var offsets_count: int = 10
@export var pattern: SpawnPattern
@export var size: Enums.Size:
	set(value):
		pattern.radius = value
	get:
		if pattern == null:
			return Enums.Size.POINT
		return pattern.radius


func _get_tool_buttons():
	return [
		create_offsets_bulk,
		generate_edge,
	]


func create_offsets_bulk():
	var container: Node2D = %Offsets

	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
		print("clear")

	var shape: CollisionShape2D = %Shape
	(shape.shape as CircleShape2D).radius = Enums.Size.GIANT
	var points: Array = []
	var tries: int = 0
	var max_points = offsets_count if !get_max_points else GameSettings.MAX_INT
	while points.size() < max_points && tries < 1000:
		tries += 1
		var r = 250 * sqrt(randf())
		var angle = 2.0 * PI * randf()
		var x = r * cos(angle)
		var y = r * sin(angle)
		var new_point = Vector2(x, y)

		var is_valid = true
		for point in points:
			if point.distance_to(new_point) < spread:
				is_valid = false
				continue

		if is_valid:
			tries = 0
			points.append(new_point)

	for point in points:
		var marker: Marker2D = Marker2D.new()
		container.add_child(marker)
		marker.owner = self
		marker.global_position = point
	save_offsets()


func generate_edge():
	var container: Node2D = %Offsets

	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
		print("clear")

	for x in range(map.spawn_rect.position.x, map.spawn_rect.end.x, Spread.MEDIUM):
		var point = Vector2(x, map.spawn_rect.position.y + 30)
		var opposite = Vector2(x * -1, (map.spawn_rect.end.y) - randi_range(1, 3) * 30)
		for p in [point, opposite]:
			var marker: Marker2D = Marker2D.new()
			container.add_child(marker)
			marker.owner = self
			marker.global_position = p
	for y in range(
		map.spawn_rect.position.y + Spread.TIGHT, map.spawn_rect.end.y - Spread.TIGHT, Spread.MEDIUM
	):
		var point = Vector2(map.spawn_rect.position.x + 30, y + 30)
		var opposite = Vector2(map.spawn_rect.end.x - 30, y - 30)
		for p in [point, opposite]:
			var marker: Marker2D = Marker2D.new()
			container.add_child(marker)
			marker.owner = self
			marker.global_position = p
	save_offsets()


func save_offsets():
	var container: Node2D = %Offsets
	var offsets: Array = []
	for child in container.get_children():
		if map.spawn_rect.has_point(child.global_position):
			offsets.append(child.position)
	pattern.offsets = offsets
