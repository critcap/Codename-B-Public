extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var a = test.new()
	var b = test.new()
	var arr = [a,b]
	arr = _meth1(arr)
	
	print(a.map, b.map)
	arr[0].map.get_or_add("asda", "penis")
	print(a.map, b.map)
	
func _meth1(array) -> Array:
	var dict = {}
	for a in array:
		a.map = dict
	return array
	
class test extends Object:
	var map: Dictionary
