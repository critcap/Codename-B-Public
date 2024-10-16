extends Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "Bullets in Tree %d" % get_tree().get_node_count_in_group("Projectile")
