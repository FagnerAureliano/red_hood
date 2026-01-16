extends BaseEnemy
class_name Spider

func _attack() -> void:
	_enemy_texture.action_animate("attack")