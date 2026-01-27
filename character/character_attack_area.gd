extends Area2D
class_name CharacterAttackArea

@export_category("Variables")
@export var _attack_damage: int = 10	
func _on_body_entered(_body: Node2D) -> void:
	if _body is BaseEnemy:
		_body.update_health(_attack_damage, get_parent())  # Example damage value
		global.spawn_impact_spark(_body.global_position)
		
		var attacker := get_parent()
		if attacker:
			# if attacker.get("_character_texture"):
			# 	global.spawn_slash(_body.global_position, attacker._character_texture.flip_h)
			
			if attacker.has_method("camera_shake"):
				attacker.camera_shake()
		print("Character attack area hit an enemy!")
	pass # Replace with function body.
