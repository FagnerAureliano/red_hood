extends ThrowableComponent

class_name CharacterBow


func _on_body_entered(_body: Node2D) -> void:
	if _body is BaseEnemy:
		_body.update_health(damage, self)
		global.spawn_impact_spark(global_position)
		# queue_free()

	if _body is TileMapLayer or _body is TileMap or _body is StaticBody2D:
		queue_free()
