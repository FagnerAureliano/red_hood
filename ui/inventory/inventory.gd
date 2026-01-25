extends Control

class_name InventoryUI

const _INVENTORY_SIZE: int = 18

const _INVENTORY_SLOT: PackedScene = preload("res://ui/inventory/inventory_slot.tscn")


@export_category("Objects")
@export var _slots_container: GridContainer

func _ready() -> void:
	global.ui_inventory = self
	for i in _INVENTORY_SIZE:
		var _inventory_slot = _INVENTORY_SLOT.instantiate()
		_slots_container.add_child(_inventory_slot)

func update_inventory(_index: int, _inventory_data: Dictionary) -> void:
	var _slot := _slots_container.get_child(_index)
	if _slot == null:
		return
	if _slot is InventorySlotUI:
		_slot.update_slot(_inventory_data)
