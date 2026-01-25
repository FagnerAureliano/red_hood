extends Button

class_name InventorySlotUI

@export_category("Objects")
@export var _slot_texture: TextureRect
@export var _amount_label: Label

func update_slot(_item_data: Dictionary) -> void:
   _slot_texture.texture = load(_item_data["path"])
   if _item_data["type"] == "resource":
       _amount_label.text = str(_item_data["amount"])
   else:
       _amount_label.text = ""