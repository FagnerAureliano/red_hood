extends Button

class_name InventorySlotUI

var _amount: int = 0

@export_category("Objects")
@export var _slot_texture: TextureRect

func update_slot(_item_data: Dictionary) -> void:
   _slot_texture.texture = load(_item_data["path"])
   _amount = _item_data["amount"]