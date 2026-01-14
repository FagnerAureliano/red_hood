extends ThrowableComponent

class_name CharacterBow


func _on_body_entered(_body: Node2D) -> void:
	if _body is TileMap:
		queue_free()
