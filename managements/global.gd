extends Node

class_name Global

const damage_popup_scene: PackedScene = preload("res://ui/damage_popup/damage_popup.tscn")

@export_category("UI")
@export var show_damage_numbers: bool = true


func spawn_effect(_path: String, _offset: Vector2, _initial_position: Vector2, _is_flipped: bool) -> void:
	var scene: PackedScene = load(_path) as PackedScene
	if scene == null:
		return

	var _effect := scene.instantiate()
	if _effect == null:
		return
	if _effect is Node2D:
		_effect.global_position = _initial_position + _offset
	elif _effect is Control:
		_effect.global_position = _initial_position + _offset
	if _effect is Object and ("flip_h" in _effect):
		_effect.flip_h = _is_flipped
	

	# get_tree().root.call_deferred("add_child", _effect)
	get_tree().current_scene.add_child(_effect)


func spawn_damage_popup(amount: int, _initial_position: Vector2, _offset: Vector2 = Vector2(0, -24)) -> void:
	if not show_damage_numbers:
		return
	var popup := damage_popup_scene.instantiate()
	if popup == null:
		return
	if popup is Object and ("amount" in popup):
		popup.amount = amount
	if popup is Control:
		popup.global_position = _initial_position + _offset
	elif popup is Node2D:
		popup.global_position = _initial_position + _offset
	get_tree().current_scene.add_child(popup)
