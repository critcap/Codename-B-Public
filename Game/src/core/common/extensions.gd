class_name NodeEx

## Adds a child to a node, returning the child.
static func add_child(child: Node, parent: Node, use_readable_name: bool = false) -> Node:
	parent.add_child(child, use_readable_name)
	return child

## Reparents a node to a new parent, removing it from the previous one.
static func reparent_node(child: Node, new_parent: Node, use_readable_name: bool = false) -> Node:
	if child.get_parent() != null:
		child.get_parent().remove_child(child)
	new_parent.add_child(child, use_readable_name)	
	return child