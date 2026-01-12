extends Node

class_name Global


func spawn_effect(_path: String, _offset: Vector2, _initial_position: Vector2, _is_flipped: bool) -> void:
	var _effect: BaseEffect = load(_path).instantiate()
	_effect.global_position = _initial_position + _offset
	_effect.flip_h = _is_flipped
	

	# get_tree().root.call_deferred("add_child", _effect)
	get_tree().current_scene.add_child(_effect)