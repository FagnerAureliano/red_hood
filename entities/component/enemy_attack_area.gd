extends Area2D
class_name EnemyAttackArea


@export_category("Variables")
@export var _attack_damage: int = 10
func _on_body_entered(_body: Node2D) -> void:
	if _body is BaseCharacter:
		print("Enemy attack area hit a character!")
		_body.update_health(_attack_damage, get_parent())