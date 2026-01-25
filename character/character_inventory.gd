extends Node

class_name CharacterInventory

var _INVENTORY_SIZE: int = 18
var _inventory_data: Dictionary = {}

func _ready():
	for i in _INVENTORY_SIZE:
		_inventory_data[i] = {}
	pass

func add_item(_item: Dictionary) -> void:
	var _item_key = _item.keys()[0]
	var _item_data = _item[_item_key]
	var _item_type = _item_data.get("type", "resource")
	
	# Stack resource items
	if _item_type == "resource":
		for _slot in _inventory_data:
			if _inventory_data[_slot].has(_item_key):
				_inventory_data[_slot][_item_key]["amount"] += 1
				global.ui_inventory.update_inventory(_slot, _inventory_data[_slot][_item_key])
				return

	# Add to new slot (equipment or new resource)
	for _slot in _inventory_data:
		if _inventory_data[_slot].is_empty():
			_inventory_data[_slot] = _item.duplicate(true)
			_inventory_data[_slot][_item_key]["amount"] = 1
			global.ui_inventory.update_inventory(_slot, _inventory_data[_slot][_item_key])
			break