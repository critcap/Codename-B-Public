class_name GameStats
extends Object

var _stats: Dictionary = {}


## Returns the Stat object for the given StatType
func get_stat(type: Enums.StatType) -> Stat:
	if !_stats.has(type):
		_stats[type] = Stat.new(type, 0.0)
	return _stats[type]


func set_stat(type: Enums.StatType, value: float) -> void:
	if _stats.has(type):
		assert(false, "Double stat assignment")
		return
	_stats[type] = Stat.new(type, value)


func add_mod(mod: ModifierData) -> void:
	var stat = get_stat(mod.type)
	stat.add_mod(mod)


class StatMod:
	extends RefCounted
	var type: Enums.StatType
	var mod: Enums.ModType
	var value: float


class Stat:
	extends RefCounted

	signal value_changed(value: float)

	var id: Enums.StatType

	## The current value of the stat
	var value: float:
		get:
			return _value
	var _value: float

	var _base_value: float
	var _multi: float = 1.0
	var _addi: float = 0

	func _init(type: Enums.StatType, init_value: float = 0.0) -> void:
		_base_value = init_value
		_value = init_value
		id = type
		_calculate_value()

	func bind(target: Object, property: StringName, sync: bool = false) -> Binding:
		var callable = Callable(func(x: float): target.set(property, x))
		value_changed.connect(callable)
		if sync:
			target.set(property, _value)
		return Binding.new(self, callable)

	func get_additive() -> float:
		return _addi

	func get_multiplier() -> float:
		return _multi

	func _calculate_value() -> void:
		var new_value = (_base_value + _addi) * _multi
		if new_value != _value:
			_value = new_value
			value_changed.emit(_value)

	## Set the base value of the stat. Only works if the base value has not been set before
	func set_base(base_value: float) -> void:
		_base_value = base_value
		_calculate_value()

	## Add a mod to the stat
	func add_mod(stat_mod: ModifierData) -> void:
		if stat_mod.type != id:
			assert(false, "Mod type does not match stat type")
			push_error("Mod type does not match stat type")
			return

		var type := stat_mod.mod
		if type == Enums.ModType.MULITPLICATIVE:
			_multi += stat_mod.value / 100
		elif type == Enums.ModType.ADDITIVE:
			_addi += stat_mod.value

		_calculate_value()

	## Remove a mod from the stat
	func remove_mod(stat_mod: ModifierData) -> void:
		var type := stat_mod.mod
		if type == Enums.ModType.MULITPLICATIVE:
			_multi -= stat_mod.value / 100
		elif type == Enums.ModType.ADDITIVE:
			_addi -= stat_mod.value

		_calculate_value()

	func increase_base(new_value: float) -> void:
		_base_value += new_value
		_calculate_value()
