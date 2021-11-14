extends Node2D
class_name BaseModifier

var items = {}

#calculate the total and set that as the property
func set_calculated_value(item, property):
	var value = items[item][property].base
	for mod in items[item][property].add.values():
		value += mod
	for mod in items[item][property].mul.values():
		value *= mod
	item[property] = value

#set the base value for a property
func set_base(item, property, base):
	if !items.has(item):
		items[item] = {}
	items[item][property] = {
		base = base,
		add = {},
		mul = {}
	}
	set_calculated_value(item, property)

#add a additive modifier
func add_modifier(item, property, key, add):
	if !items.has(item):
		set_base(item, property, item[property])
	items[item][property].add[key] = add
	set_calculated_value(item, property)
	
#add a multiplying modifier
func mul_modifier(item, property, key, mul):
	if !items.has(item):
		set_base(item, property, item[property])
	items[item][property].mul[key] = mul
	set_calculated_value(item, property)

#remove a property modifier
func remove_modifier(item, property, key):
	if !items.has(item):
		set_base(item, property, item[property])
	items[item][property].mul.erase(key)
	items[item][property].add.erase(key)