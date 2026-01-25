extends Node

class_name CharacterInventory

var _INVENTORY_SIZE: int = 18
var _inventory_data: Dictionary = {}

func _ready():
	for i in _INVENTORY_SIZE:
		_inventory_data[i] = {}
	pass

func add_item(_item: Dictionary) -> void:
# Item data: { "path": "res://collectables_by_drop/spider/bow_drop.png", "type": "resource", "value": 5, "spawn_chance": 1.0 }
# Dropping item: bow_drop
# Item data: { "path": "res://collectables_by_drop/spider/bow_drop.png", "type": "equipment", "value": 1, "spawn_chance": 0.3, "attributes": { "bow": true, "damage": 10 } }
	
	for _slot in _inventory_data:

		if _inventory_data[_slot].is_empty():
			continue

		var _slot_keys: Array = _inventory_data[_slot].keys()
		var _slot_item_name: String = _slot_keys[0]
 
		if _slot_keys[0] == _item.keys()[0]:
			if _item[_item.keys()[0]]["type"] == "equipment":
				_inventory_data[_slot][_slot_item_name]["amount"] += 1
				global.ui_inventory.update_inventory(_slot, _inventory_data[_slot][_slot_item_name])
				return
 

	for slot in _inventory_data:
		if _inventory_data[slot] == {}:
			_inventory_data[slot] = _item
			var _slot_keys: Array = _inventory_data[slot].keys()
			var _slot_item_name: String = _slot_keys[0]
			_inventory_data[slot][_slot_item_name]["amount"] = 1
			global.ui_inventory.update_inventory(slot, _inventory_data[slot][_slot_item_name])
			break