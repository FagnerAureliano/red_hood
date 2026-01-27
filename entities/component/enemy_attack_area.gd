extends Area2D
class_name EnemyAttackArea


@export_category("Variables")
@export var _attack_damage: int = 10
func _on_body_entered(_body: Node2D) -> void:
	if _body is BaseCharacter:
		print("Enemy attack area hit a character!")
		_body.update_health(_attack_damage, get_parent())
		global.spawn_impact_spark(_body.global_position)		
		var attacker = get_parent()
		if attacker and attacker.get("_enemy_texture"):
			global.spawn_slash(_body.global_position, attacker._enemy_texture.flip_h)