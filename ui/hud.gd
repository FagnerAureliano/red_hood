extends CanvasLayer

class_name HUD


@export_category("Objects")
@export var _inventory_ui: InventoryUI


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_inventory"):
		_toggle_inventory()

func _toggle_inventory() -> void:
	_inventory_ui.visible = not _inventory_ui.visible
